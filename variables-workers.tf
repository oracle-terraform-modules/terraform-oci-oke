# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

#
# Cluster
#

variable "cluster_id" {
  default     = null
  description = "An existing OKE cluster OCID when `create_cluster = false`."
  type        = string
}

variable "cluster_ca_cert" {
  default     = null
  description = "Base64+PEM-encoded cluster CA certificate for unmanaged instance pools. Determined automatically when 'create_cluster' = true or 'cluster_id' is provided."
  type        = string
}

variable "cluster_dns" {
  default     = "10.96.5.5"
  description = "Cluster DNS resolver IP address. The provided value used with default 'servicesCidr' 10.96.0.0/16 should only require modification in the case of conflict."
  type        = string
}

#
# Worker pools
#

variable "worker_pools" {
  default     = {}
  description = "Tuple of OKE worker pools where each key maps to the OCID of an OCI resource, and value contains its definition."
  type        = any
}

variable "worker_pool_enabled" {
  default     = true
  description = "Whether to apply resources for a group when unspecified."
  type        = bool
}

variable "worker_pool_mode" {
  default     = "node-pool"
  description = "Default management mode for worker pools when unspecified. Only 'node-pool' is currently supported."
  type        = string
  validation {
    condition     = contains(["node-pool", "instance-pool", "cluster-network"], var.worker_pool_mode)
    error_message = "Accepted values are node-pool, instance-pool, or cluster-network"
  }
}

variable "worker_pool_size" {
  default     = 0
  description = "Default size for worker pools when unspecified."
  type        = number
}

variable "output_worker_detail" {
  default     = false
  description = "Whether to include detailed output for worker pool configuration."
  type        = bool
}

#
# Workers: network
#

variable "worker_type" {
  default     = "private"
  description = "Whether to provision public or private workers."
  type        = string
  validation {
    condition     = contains(["public", "private"], var.worker_type)
    error_message = "Accepted values are public or private."
  }
}

variable "worker_nsg_ids" {
  default     = []
  description = "An additional list of network security group (NSG) IDs for node security."
  type        = list(string)
}

variable "pod_nsg_ids" {
  default     = []
  description = "An additional list of network security group (NSG) IDs for pod security."
  type        = list(string)
}

variable "kubeproxy_mode" {
  default     = "iptables"
  description = "The mode in which to run kube-proxy."
  type        = string

  validation {
    condition     = contains(["iptables", "ipvs"], var.kubeproxy_mode)
    error_message = "Accepted values are iptables or ipvs."
  }
}

#
# Workers: instance
#

variable "worker_block_volume_type" {
  default     = "paravirtualized"
  description = "The default block volume attachment type for Instance Configurations."
  type        = string
  validation {
    condition     = contains(["iscsi", "paravirtualized"], var.worker_block_volume_type)
    error_message = "Accepted values are 'iscsi' or 'paravirtualized'."
  }
}

variable "worker_node_labels" {
  default     = {}
  description = "Default worker node labels. Merged with labels defined on each pool."
  type        = map(string)
}

variable "worker_image_id" {
  default     = null
  description = "Default image for worker pools when unspecified"
  type        = string
}

variable "worker_image_type" {
  default     = "oke"
  description = "Whether to use a platform, OKE, or custom image for worker nodes by default. When custom is set, the worker_image_id must be specified."
  type        = string
  validation {
    condition     = contains(["custom", "oke", "platform"], var.worker_image_type)
    error_message = "Accepted values are custom, oke, platform"
  }
}

variable "worker_image_os" {
  default     = "Oracle Linux"
  description = "Default worker image operating system name when worker_image_type = 'oke' or 'platform'."
  type        = string
}

variable "worker_image_os_version" {
  default     = "8"
  description = "Default worker image operating system version when worker_image_type = 'oke' or 'platform'."
  type        = string
}

variable "worker_shape" {
  default = {
    shape            = "VM.Standard.E4.Flex",
    ocpus            = 2,
    memory           = 16,
    boot_volume_size = 50
  }
  description = "Default shape of the created worker instance."
  type        = map(any)
}

variable "worker_cloud_init" {
  default     = []
  description = "List of maps containing cloud init MIME part configuration. See https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config.html#part for expected schema of each element."
  type        = list(map(string))
}

variable "worker_volume_kms_key_id" {
  default     = null
  description = "The ID of the OCI KMS key to be used as the master encryption key for Boot Volume and Block Volume encryption."
  type        = string
}

variable "worker_pv_transit_encryption" {
  default     = false
  description = "Whether to enable in-transit encryption for the data volume's paravirtualized attachment."
  type        = bool
}

variable "max_pods_per_node" {
  default     = 31
  description = "The maximum number of pods to deploy per node. Absolute maximum is 110. Ignored when when cni_type != 'npn'."
  type        = number

  validation {
    condition     = var.max_pods_per_node > 0 && var.max_pods_per_node <= 110
    error_message = "Must be between 1 and 110."
  }
}

#
# FSS
#

variable "create_fss" {
  default     = false
  description = "Whether to enable provisioning for FSS."
  type        = bool
}

variable "fss_availability_domain" {
  default     = null
  description = "The availability domain for FSS placement. Defaults to first available."
  type        = string
}

variable "fss_nsg_ids" {
  default     = []
  description = "A list of network security group (NSG) ids for FSS mount targets."
  type        = list(string)
}

variable "fss_mount_path" {
  default     = "/oke_fss"
  description = "FSS mount path to be associated."
  type        = string
}

variable "fss_max_fs_stat_bytes" {
  default     = 23843202333
  description = "Maximum tbytes, fbytes, and abytes, values reported by NFS FSSTAT calls through any associated mount targets."
  type        = number
}

variable "fss_max_fs_stat_files" {
  default     = 223442
  description = "Maximum tfiles, ffiles, and afiles values reported by NFS FSSTAT."
  type        = number
}

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
  default     = null
  description = "Cluster DNS resolver IP address. Determined automatically when not set (recommended)."
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

variable "worker_pool_mode" {
  default     = "node-pool"
  description = "Default management mode for workers when unspecified on a pool."
  type        = string
  validation {
    condition = contains([
      "node-pool",
      "virtual-node-pool",
      "instance",
      "instance-pool",
      "cluster-network"
    ], var.worker_pool_mode)
    error_message = "Accepted values are node-pool, virtual-node-pool, instance, instance-pool, or cluster-network."
  }
}

variable "worker_pool_size" {
  default     = 0
  description = "Default size for worker pools when unspecified on a pool."
  type        = number
}

#
# Workers: Compute clusters
#

variable "worker_compute_clusters" {
  default     = {}
  description = "Whether to create compute clusters shared by nodes across multiple worker pools enabled for 'compute-cluster'."
  type        = map(any)
}

#
# Workers: network
#

variable "worker_is_public" {
  default     = false
  description = "Whether to provision workers with public IPs allocated by default when unspecified on a pool."
  type        = bool
}

variable "worker_nsg_ids" {
  default     = []
  description = "An additional list of network security group (NSG) IDs for node security. Combined with 'nsg_ids' specified on each pool."
  type        = list(string)
}

variable "pod_nsg_ids" {
  default     = []
  description = "An additional list of network security group (NSG) IDs for pod security. Combined with 'pod_nsg_ids' specified on each pool."
  type        = list(string)
}

variable "kubeproxy_mode" {
  default     = "iptables"
  description = "The mode in which to run kube-proxy when unspecified on a pool."
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
  description = "Default block volume attachment type for Instance Configurations when unspecified on a pool."
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

variable "worker_node_metadata" {
  default     = {}
  description = "Map of additional worker node instance metadata. Merged with metadata defined on each pool."
  type        = map(string)
}

variable "worker_image_id" {
  default     = null
  description = "Default image for worker pools  when unspecified on a pool."
  type        = string
}

variable "worker_image_type" {
  default     = "oke"
  description = "Whether to use a platform, OKE, or custom image for worker nodes by default when unspecified on a pool. When custom is set, the worker_image_id must be specified."
  type        = string
  validation {
    condition     = contains(["custom", "oke", "platform"], var.worker_image_type)
    error_message = "Accepted values are custom, oke, platform"
  }
}

variable "worker_image_os" {
  default     = "Oracle Linux"
  description = "Default worker image operating system name when worker_image_type = 'oke' or 'platform' and unspecified on a pool."
  type        = string
}

variable "worker_image_os_version" {
  default     = "8"
  description = "Default worker image operating system version when worker_image_type = 'oke' or 'platform' and unspecified on a pool."
  type        = string
}

variable "worker_shape" {
  default = {
    shape            = "VM.Standard.E4.Flex"
    ocpus            = 2
    memory           = 16
    boot_volume_size = 50

    # https://docs.oracle.com/en-us/iaas/Content/Block/Concepts/blockvolumeperformance.htm
    # Supported for mode = "cluster-network" | "instance-pool" | "instance" (self-managed) only
    boot_volume_vpus_per_gb = 10 # 10: Balanced, 20: High, 30-120: Ultra High (requires multipath)
  }
  description = "Default shape of the created worker instance when unspecified on a pool."
  type        = map(any)
}

variable "worker_capacity_reservation_id" {
  default     = null
  description = "The ID of the Compute capacity reservation the worker node will be launched under. See <a href=https://docs.oracle.com/en-us/iaas/Content/Compute/Tasks/reserve-capacity.htm>Capacity Reservations</a> for more information."
  type        = string
}

variable "worker_preemptible_config" {
  default = {
    enable                  = false,
    is_preserve_boot_volume = false
  }
  description = "Default preemptible Compute configuration when unspecified on a pool. See <a href=https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengusingpreemptiblecapacity.htm>Preemptible Worker Nodes</a> for more information."
  type        = map(any)
}

variable "worker_cloud_init" {
  default     = []
  description = "List of maps containing cloud init MIME part configuration for worker nodes. Merged with pool-specific definitions. See https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config.html#part for expected schema of each element."
  type        = list(map(string))
}

variable "worker_disable_default_cloud_init" {
  default     = false
  description = "Whether to disable the default OKE cloud init and only use the cloud init explicitly passed to the worker pool in 'worker_cloud_init'."
  type        = bool
}

variable "worker_volume_kms_key_id" {
  default     = null
  description = "The ID of the OCI KMS key to be used as the master encryption key for Boot Volume and Block Volume encryption by default when unspecified on a pool."
  type        = string
}

variable "worker_pv_transit_encryption" {
  default     = false
  description = "Whether to enable in-transit encryption for the data volume's paravirtualized attachment by default when unspecified on a pool."
  type        = bool
}

variable "max_pods_per_node" {
  default     = 31
  description = "The default maximum number of pods to deploy per node when unspecified on a pool. Absolute maximum is 110. Ignored when when cni_type != 'npn'."
  type        = number

  validation {
    condition     = var.max_pods_per_node > 0 && var.max_pods_per_node <= 110
    error_message = "Must be between 1 and 110."
  }
}

variable "platform_config" {
  default     = null
  description = "Default platform_config for self-managed worker pools created with mode: 'instance', 'instance-pool', or 'cluster-network'. See <a href=https://docs.oracle.com/en-us/iaas/api/#/en/iaas/20160918/datatypes/PlatformConfig>PlatformConfig</a> for more information."
  type = object({
    type                                           = optional(string),
    are_virtual_instructions_enabled               = optional(bool),
    is_access_control_service_enabled              = optional(bool),
    is_input_output_memory_management_unit_enabled = optional(bool),
    is_measured_boot_enabled                       = optional(bool),
    is_memory_encryption_enabled                   = optional(bool),
    is_secure_boot_enabled                         = optional(bool),
    is_symmetric_multi_threading_enabled           = optional(bool),
    is_trusted_platform_module_enabled             = optional(bool),
    numa_nodes_per_socket                          = optional(number),
    percentage_of_cores_enabled                    = optional(bool),
  })
}

variable "agent_config" {
  default     = null
  description = "Default agent_config for self-managed worker pools created with mode: 'instance', 'instance-pool', or 'cluster-network'. See <a href=https://docs.oracle.com/en-us/iaas/api/#/en/iaas/20160918/datatypes/InstanceAgentConfig for more information."
  type = object({
    are_all_plugins_disabled = bool,
    is_management_disabled   = bool,
    is_monitoring_disabled   = bool,
    plugins_config           = map(string),
  })
}

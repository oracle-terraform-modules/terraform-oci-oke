# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Common

variable "state_id" {
  default     = null
  description = "Optional Terraform state_id from an existing deployment of the module to re-use with created resources."
  type        = string
}

variable "compartment_id" {
  default     = null
  description = "The compartment id where resources will be created."
  type        = string
}

variable "tenancy_id" {
  default     = null
  description = "The tenancy id of the OCI Cloud Account in which to create the resources."
  type        = string
}

# Tags

variable "freeform_tags" {
  default     = {}
  description = "Freeform tags to be applied to created resources."
  type        = map(string)
}

variable "defined_tags" {
  default     = {}
  description = "Defined tags to be applied to created resources. Must already exist in the tenancy."
  type        = map(string)
}

variable "use_defined_tags" {
  default     = false
  description = "Whether to apply defined tags to created resources for IAM policy and tracking."
  type        = bool
}

variable "tag_namespace" {
  default     = "oke"
  description = "The tag namespace for standard OKE defined tags."
  type        = string
}

# Cluster

variable "apiserver_private_host" { type = string }

variable "cluster_id" {
  default     = null
  description = "An existing OKE cluster OCID when `create_cluster = false`."
  type        = string
}

variable "cluster_type" {
  default     = "basic"
  description = "The cluster type. See <a href=https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengworkingwithenhancedclusters.htm>Working with Enhanced Clusters and Basic Clusters</a> for more information."
  type        = string
  validation {
    condition     = contains(["basic", "enhanced"], lower(var.cluster_type))
    error_message = "Accepted values are 'basic' or 'enhanced'."
  }
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

variable "kubernetes_version" {
  default     = "v1.26.2"
  description = "The version of Kubernetes used for worker nodes."
  type        = string
}

# Network

variable "assign_dns" { type = bool }
variable "assign_public_ip" { type = bool }

variable "cni_type" {
  default     = "flannel"
  description = "The CNI for the cluster: 'flannel' or 'npn'. See <a href=https://docs.oracle.com/en-us/iaas/Content/ContEng/Concepts/contengpodnetworking.htm>Pod Networking</a>."
  type        = string
  validation {
    condition     = contains(["flannel", "npn"], var.cni_type)
    error_message = "Accepted values are flannel or npn"
  }
}

variable "pod_subnet_id" { type = string }
variable "worker_subnet_id" { type = string }

# Worker pools

variable "worker_pools" {
  default     = {}
  description = "Tuple of OKE worker pools where each key maps to the OCID of an OCI resource, and value contains its definition."
  type        = any
}

variable "worker_pool_mode" {
  default     = "node-pool"
  description = "Default management mode for workers when unspecified on a pool. Only 'node-pool' is currently supported."
  type        = string
  validation {
    condition     = contains(["node-pool", "instance", "instance-pool", "cluster-network"], var.worker_pool_mode)
    error_message = "Accepted values are node-pool, instance-pool, or cluster-network"
  }
}

variable "worker_pool_size" {
  default     = 0
  description = "Default size for worker pools when unspecified on a pool."
  type        = number
}

# Workers: instance

variable "ad_numbers_to_names" { type = map(string) }
variable "ad_numbers" { type = list(number) }

variable "image_ids" {
  default     = {}
  description = "Map of images for filtering with image_os and image_os_version."
  type        = any
}

variable "indexed_images" {
  default     = {}
  description = "Map of images."
  type        = any
}

variable "ssh_public_key" {
  default     = null
  description = "The contents of the SSH public key file. Used to allow login for workers/bastion/operator with corresponding private key."
  type        = string
}

variable "timezone" { type = string }

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

variable "block_volume_type" {
  default     = "paravirtualized"
  description = "Default block volume attachment type for Instance Configurations when unspecified on a pool."
  type        = string
  validation {
    condition     = contains(["iscsi", "paravirtualized"], var.block_volume_type)
    error_message = "Accepted values are 'iscsi' or 'paravirtualized'."
  }
}

variable "node_labels" {
  default     = {}
  description = "Default worker node labels. Merged with labels defined on each pool."
  type        = map(string)
}


variable "node_metadata" {
  default     = {}
  description = "Map of additional worker node instance metadata. Merged with metadata defined on each pool."
  type        = map(string)
}

variable "image_id" {
  default     = null
  description = "Default image for worker pools  when unspecified on a pool."
  type        = string
}

variable "image_type" {
  default     = "oke"
  description = "Whether to use a platform, OKE, or custom image for worker nodes by default when unspecified on a pool. When custom is set, the worker_image_id must be specified."
  type        = string
  validation {
    condition     = contains(["custom", "oke", "platform"], var.image_type)
    error_message = "Accepted values are custom, oke, platform"
  }
}

variable "image_os" {
  default     = "Oracle Linux"
  description = "Default worker image operating system name when worker_image_type = 'oke' or 'platform' and unspecified on a pool."
  type        = string
}

variable "image_os_version" {
  default     = "8"
  description = "Default worker image operating system version when worker_image_type = 'oke' or 'platform' and unspecified on a pool."
  type        = string
}

variable "shape" {
  default = {
    shape            = "VM.Standard.E4.Flex",
    ocpus            = 2,
    memory           = 16,
    boot_volume_size = 50
  }
  description = "Default shape of the created worker instance when unspecified on a pool."
  type        = map(any)
}

variable "capacity_reservation_id" {
  default     = null
  description = "The ID of the Compute capacity reservation the worker node will be launched under. See <a href=https://docs.oracle.com/en-us/iaas/Content/Compute/Tasks/reserve-capacity.htm>Capacity Reservations</a> for more information."
  type        = string
}

variable "preemptible_config" {
  default = {
    enable                  = false,
    is_preserve_boot_volume = false
  }
  description = "Default preemptible Compute configuration when unspecified on a pool. See <a href=https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengusingpreemptiblecapacity.htm>Preemptible Worker Nodes</a> for more information."
  type        = map(any)
}

variable "cloud_init" {
  default     = []
  description = "List of maps containing cloud init MIME part configuration for worker nodes. Merged with pool-specific definitions. See https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config.html#part for expected schema of each element."
  type        = list(map(string))
}

variable "disable_default_cloud_init" {
  default     = false
  description = "Whether to disable the default OKE cloud init and only use the cloud init explicitly passed to the worker pool in 'worker_cloud_init'."
  type        = bool
}

variable "volume_kms_key_id" {
  default     = null
  description = "The ID of the OCI KMS key to be used as the master encryption key for Boot Volume and Block Volume encryption by default when unspecified on a pool."
  type        = string
}

variable "pv_transit_encryption" {
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
  description = "Default agent_config for self-managed worker pools created with mode: 'instance', 'instance-pool', or 'cluster-network'. See <a href=https://docs.oracle.com/en-us/iaas/api/#/en/iaas/20160918/datatypes/InstanceAgentConfig for more information."
  type = object({
    are_all_plugins_disabled = bool,
    is_management_disabled   = bool,
    is_monitoring_disabled   = bool,
    plugins_config           = map(string),
  })
}

#
# Workers: compute-cluster
#

variable "compute_clusters" {
  default     = {}
  description = "Whether to create compute clusters shared by nodes across multiple worker pools enabled for 'compute-cluster'."
  type        = map(any)
}
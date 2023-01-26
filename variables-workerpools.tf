# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

variable "cluster_id" {
  default     = ""
  description = "An existing OKE cluster ID when `mode = node-pool`"
  type        = string
}

variable "cluster_ca_cert" {
  default     = ""
  description = "Required for unmanaged instance pools for secure control plane connection"
  type        = string
}

variable "sriov_num_vfs" {
  default     = 1
  description = "Number of SR-IOV virtual functions to create for each physical function on Mellanox NICs when present. 0 to disable."
  type        = number
}

variable "worker_pool_boot_volume_size" {
  default     = 50
  description = "Default size in GB for the boot volume of created worker nodes"
  type        = number
}

variable "worker_pool_enabled" {
  default     = true
  description = "Whether to apply resources for a group when unspecified"
  type        = bool
}

variable "worker_pools" {
  default     = {}
  description = "Tuple of OKE worker pools where each key maps to the OCID of an OCI resource, and value contains its definition"
  type        = any
}

variable "worker_pool_mode" {
  default     = "node-pool"
  description = "Default management mode for worker pools when unspecified. Only node-pool is currently supported."
  type        = string
  validation {
    condition     = contains(["node-pool", "instance-pool", "cluster-network"], var.worker_pool_mode)
    error_message = "Accepted values are node-pool, instance-pool, or cluster-network"
  }
}

variable "worker_pool_size" {
  default     = 0
  description = "Default size for worker pools when unspecified"
  type        = number
}

variable "worker_pool_image_id" {
  default     = ""
  description = "Default image for worker pools when unspecified"
  type        = string
}

variable "worker_pool_shape" {
  default     = "VM.Standard.E4.Flex"
  description = "Default shape for instance pools when undefined"
  type        = string
}

variable "worker_pool_ocpus" {
  description = "Default ocpus for flex shapes"
  default     = 1
  type        = number
}

variable "worker_pool_memory" {
  default     = 16
  description = "Default memory in GB for flex shapes"
  type        = number
}

variable "worker_pool_image_type" {
  default     = "custom"
  description = "Whether to use a Platform, OKE or custom image. When custom is set, the worker_pool_image_id must be specified."
  type        = string
  validation {
    condition     = contains(["custom", "oke", "platform"], var.worker_pool_image_type)
    error_message = "Accepted values are custom, oke, platform"
  }
}

variable "worker_pool_subnet_id" {
  default     = ""
  description = "The subnet OCID used for instances"
  type        = string
}

variable "worker_pool_cloudinit" {
  default     = ""
  description = "Base64-encoded cloud init script to run on worker node boot"
  type        = string
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

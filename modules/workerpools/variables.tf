# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

variable "enabled" {
  default     = true
  description = "Whether to apply resources for a worker pool when unspecified on its definition"
  type        = bool
}

variable "mode" {
  default     = "node-pool"
  description = "Default management mode for worker pools when unspecified"
  type        = string
  validation {
    condition     = contains(["node-pool", "instance-pool", "cluster-network"], var.mode)
    error_message = "Accepted values are node-pool, instance-pool, or cluster-network"
  }
}

variable "size" {
  default     = 0
  description = "Default number of desired nodes for created worker pools"
  type        = number
  validation {
    condition     = var.size >= 0
    error_message = "Default worker pool size must be >= 0"
  }
}

variable "defined_tags" {
  default     = {}
  description = "Tags to apply to created resources"
  type        = map(string)
}

variable "freeform_tags" {
  default     = {}
  description = "Tags to apply to created resources"
  type        = map(string)
}

variable "node_labels" {
  default     = {}
  description = "Default Kubernetes node labels applied to worker pools, merged with group-level labels."
  type        = map(string)
}

variable "timezone" {
  default     = "Etc/UTC"
  description = "The preferred timezone for the worker nodes"
  type        = string
}

variable "volume_kms_key_id" {
  default     = ""
  description = "The OCID of the OCI KMS key to be used as the master encryption key for Boot Volume and Block Volume encryption. Oracle-managed encryption if null."
  type        = string
}

variable "block_volume_type" {
  default     = "paravirtualized"
  description = "The default block volume attachment type for Instance Configurations."
  type        = string
  validation {
    condition     = contains(["iscsi", "paravirtualized"], var.block_volume_type)
    error_message = "Accepted values are iscsi or paravirtualized"
  }
}

variable "subnet_id" {
  description = "The subnet OCID used for instances"
  type        = string
}

variable "enable_pv_encryption_in_transit" {
  description = "Whether to enable in-transit encryption for the data volume's paravirtualized attachment. This field applies to both block volumes and boot volumes. The default value is false"
  type        = bool
  default     = false
}

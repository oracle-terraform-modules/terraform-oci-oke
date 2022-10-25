# Copyright (c) 2022 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

variable "enabled" {
  default     = true
  description = "Default for whether to apply resources for a group"
  type        = bool
}

variable "defined_tags" {
  type        = map(string)
  description = "Tags to apply to created resources"
  default     = {}
}

variable "freeform_tags" {
  type        = map(string)
  description = "Tags to apply to created resources"
  default     = {}
}

variable "mode" {
  default     = "node-pool"
  description = "Default management mode for worker groups when unspecified"
  type        = string
  validation {
    condition     = contains(["node-pool", "instance-pool", "cluster-network"], var.mode)
    error_message = "Accepted values are node-pool, instance-pool, or cluster-network"
  }
}

variable "timezone" {
  default     = "Etc/UTC"
  description = "The preferred timezone for the worker nodes"
  type        = string
}

variable "worker_groups" {
  default     = {}
  description = "Tuple of OKE worker groups where each key maps to the OCID of an OCI resource, and value contains its definition"
  type        = any
}

variable "enable_pv_encryption_in_transit" {
  description = "Whether to enable in-transit encryption for the data volume's paravirtualized attachment. This field applies to both block volumes and boot volumes. The default value is false"
  type        = bool
  default     = false
}

variable "use_volume_encryption" {
  description = "Whether to use OCI KMS to encrypt Kubernetes Nodepool's boot/block volume."
  type        = bool
  default     = false
}

variable "volume_kms_key_id" {
  default     = ""
  description = "The OCID of the OCI KMS key to be used as the master encryption key for Boot Volume and Block Volume encryption."
  type        = string
}

variable "kubeproxy_mode" {
  default     = "iptables"
  description = "The kube-proxy mode to use for a worker node."
  type        = string
  validation {
    condition     = contains(["iptables", "ipvs"], var.kubeproxy_mode)
    error_message = "Accepted values are iptables or ipvs."
  }
}
# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

variable "await_node_readiness" {
  default     = "none"
  description = "Optionally block completion of Terraform apply until one/all worker nodes become ready."
  type        = string

  validation {
    condition     = contains(["none", "one", "all"], var.await_node_readiness)
    error_message = "Accepted values are 'none', 'one' or 'all'."
  }
}

# Oracle Container Image Registry (OCIR)

variable "ocir_email_address" {
  default     = null
  description = "The email address used for the Oracle Container Image Registry (OCIR)."
  type        = string
}

variable "ocir_secret_id" {
  default     = null
  description = "The OCI Vault secret ID for the OCIR authentication token."
  type        = string
}

variable "ocir_secret_name" {
  default     = "ocirsecret"
  description = "The name of the Kubernetes secret to be created with the OCIR authentication token."
  type        = string
}

variable "ocir_secret_namespace" {
  default     = "default"
  description = "The Kubernetes namespace in which to create the OCIR secret."
  type        = string
}

variable "ocir_username" {
  default     = null
  description = "A username with access to the OCI Vault secret for OCIR access. Required when 'ocir_secret_id' is provided."
  type        = string
}

# Worker pool draining

variable "worker_drain_ignore_daemonsets" {
  default     = true
  description = "Whether to ignore DaemonSet-managed Pods when draining worker pools. See <a href=https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#drain>kubectl drain</a> for more information."
  type        = bool
}

variable "worker_drain_delete_local_data" {
  default     = true
  description = "Whether to accept removal of data stored locally on draining worker pools. See <a href=https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#drain>kubectl drain</a> for more information."
  type        = bool
}

variable "worker_drain_timeout_seconds" {
  default     = 900
  description = "The length of time to wait before giving up on draining nodes in a pool. See <a href=https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#drain>kubectl drain</a> for more information."
  type        = number
}

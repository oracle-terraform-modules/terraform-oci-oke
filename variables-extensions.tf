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

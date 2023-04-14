# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  tenancy_id            = coalesce(var.tenancy_id, var.tenancy_ocid, "unknown")
  compartment_id        = coalesce(var.compartment_id, var.compartment_ocid, var.tenancy_id)
  worker_compartment_id = coalesce(var.worker_compartment_id, var.compartment_id)
  user_id               = var.user_id != "" ? var.user_id : var.current_user_ocid
  home_region           = coalesce(var.home_region, var.region)

  api_private_key = sensitive(
    var.api_private_key != ""
    ? try(base64decode(var.api_private_key), var.api_private_key)
    : var.api_private_key_path != ""
    ? file(var.api_private_key_path)
    : null
  )
}

# Overrides Resource Manager
variable "tenancy_id" {
  default     = null
  description = "The tenancy id of the OCI Cloud Account in which to create the resources."
  type        = string
}

variable "tenancy_ocid" {
  default     = null
  description = "A tenancy OCID automatically populated by Resource Manager."
  type        = string
}

# Overrides Resource Manager
variable "user_id" {
  default     = null
  description = "The id of the user that terraform will use to create the resources."
  type        = string
}

# Automatically populated by Resource Manager
variable "current_user_ocid" {
  default     = null
  description = "A user OCID automatically populated by Resource Manager."
  type        = string
}

# Overrides Resource Manager
variable "compartment_id" {
  default     = null
  description = "The compartment id where resources will be created."
  type        = string
}

# Automatically populated by Resource Manager
variable "compartment_ocid" {
  default     = null
  description = "A compartment OCID automatically populated by Resource Manager."
  type        = string
}

# Overrides compartment_[oc]id
variable "worker_compartment_id" {
  default     = null
  description = "The compartment id where worker group resources will be created."
  type        = string
}

variable "network_compartment_id" {
  default     = null
  description = "The compartment id where network resources will be created."
  type        = string
}

# Automatically populated by Resource Manager
# List of regions: https://docs.cloud.oracle.com/iaas/Content/General/Concepts/regions.htm#ServiceAvailabilityAcrossRegions
variable "region" {
  default     = "us-ashburn-1"
  description = "The OCI region where OKE resources will be created."
  type        = string
}

# List of regions: https://docs.cloud.oracle.com/iaas/Content/General/Concepts/regions.htm#ServiceAvailabilityAcrossRegions
variable "home_region" {
  default     = null
  description = "The tenancy's home region. Required to perform identity operations."
  type        = string
}

variable "api_fingerprint" {
  default     = null
  description = "Fingerprint of the API private key to use with OCI API."
  type        = string
}

variable "api_private_key" {
  default     = null
  description = "The contents of the private key file to use with OCI API, optionally base64-encoded. This takes precedence over private_key_path if both are specified in the provider."
  sensitive   = true
  type        = string
}

variable "api_private_key_password" {
  default     = null
  description = "The corresponding private key password to use with the api private key if it is encrypted."
  sensitive   = true
  type        = string
}

variable "api_private_key_path" {
  default     = null
  description = "The path to the OCI API private key."
  type        = string
}

variable "config_file_profile" {
  default     = "DEFAULT"
  description = "The profile within the OCI config file to use."
  type        = string
}

variable "create_iam_resources" {
  default     = false
  description = "Whether to create IAM dynamic groups, policies, and tags. Resources for components may be controlled individually with 'create_iam_*' variables when enabled. Ignored when 'create_iam_resources' is false."
  type        = bool
}

variable "create_iam_autoscaler_policy" {
  default     = "auto"
  description = "Whether to create an IAM dynamic group and policy rules for Cluster Autoscaler management. Depends on configuration of associated component when set to 'auto'. Ignored when 'create_iam_resources' is false."
  type        = string
  validation {
    condition     = contains(["never", "auto", "always"], var.create_iam_autoscaler_policy)
    error_message = "Accepted values are never, auto, or always"
  }
}

variable "create_iam_kms_policy" {
  default     = "auto"
  description = "Whether to create an IAM dynamic group and policy rules for cluster autoscaler. Depends on configuration of associated components when set to 'auto'. Ignored when 'create_iam_resources' is false."
  type        = string
  validation {
    condition     = contains(["never", "auto", "always"], var.create_iam_kms_policy)
    error_message = "Accepted values are never, auto, or always"
  }
}

variable "create_iam_operator_policy" {
  default     = "auto"
  description = "Whether to create an IAM dynamic group and policy rules for operator access to the OKE control plane. Depends on configuration of associated components when set to 'auto'. Ignored when 'create_iam_resources' is false."
  type        = string
  validation {
    condition     = contains(["never", "auto", "always"], var.create_iam_operator_policy)
    error_message = "Accepted values are never, auto, or always"
  }
}

variable "create_iam_worker_policy" {
  default     = "auto"
  description = "Whether to create an IAM dynamic group and policy rules for self-managed worker nodes. Depends on configuration of associated components when set to 'auto'. Ignored when 'create_iam_resources' is false."
  type        = string
  validation {
    condition     = contains(["never", "auto", "always"], var.create_iam_worker_policy)
    error_message = "Accepted values are never, auto, or always"
  }
}

variable "create_iam_tag_namespace" {
  default     = false
  description = "Whether to create a namespace for defined tags used for IAM policy and tracking. Ignored when 'create_iam_resources' is false."
  type        = bool
}

variable "create_iam_defined_tags" {
  default     = false
  description = "Whether to create defined tags used for IAM policy and tracking. Ignored when 'create_iam_resources' is false."
  type        = bool
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

variable "freeform_tags" {
  default = {
    cluster           = {}
    persistent_volume = {}
    service_lb        = {}
    workers           = {}
    bastion           = {}
    operator          = {}
    vcn               = {}
  }
  description = "Freeform tags to be applied to created resources."
  type        = any
}

variable "defined_tags" {
  default = {
    cluster           = {}
    persistent_volume = {}
    service_lb        = {}
    workers           = {}
    bastion           = {}
    operator          = {}
    vcn               = {}
  }
  description = "Defined tags to be applied to created resources. Must already exist in the tenancy."
  type        = any
}

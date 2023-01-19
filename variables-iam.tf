# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  tenancy_id            = coalesce(var.tenancy_id, var.tenancy_ocid, "unknown")
  compartment_id        = coalesce(var.compartment_id, var.compartment_ocid, local.tenancy_id)
  worker_compartment_id = coalesce(var.worker_compartment_id, local.compartment_id)
  user_id               = var.user_id != "" ? var.user_id : var.current_user_ocid
  home_region           = coalesce(var.home_region, var.region)

  api_private_key = (
    var.api_private_key != ""
    ? try(base64decode(var.api_private_key), var.api_private_key)
    : var.api_private_key_path != ""
    ? file(var.api_private_key_path)
  : null)
}

# Overrides Resource Manager
variable "tenancy_id" {
  default     = ""
  description = "The tenancy id of the OCI Cloud Account in which to create the resources."
  type        = string
}

variable "tenancy_ocid" {
  default     = ""
  description = "A tenancy OCID automatically populated by Resource Manager."
  type        = string
}

# Overrides Resource Manager
variable "user_id" {
  default     = ""
  description = "The id of the user that terraform will use to create the resources."
  type        = string
}

# Automatically populated by Resource Manager
variable "current_user_ocid" {
  default     = ""
  description = "A user OCID automatically populated by Resource Manager."
  type        = string
}

# Overrides Resource Manager
variable "compartment_id" {
  default     = ""
  description = "The compartment id where resources will be created."
  type        = string
}

# Automatically populated by Resource Manager
variable "compartment_ocid" {
  default     = ""
  description = "A compartment OCID automatically populated by Resource Manager."
  type        = string
}

# Overrides compartment_[oc]id
variable "worker_compartment_id" {
  default     = ""
  description = "The compartment id where worker pool resources will be created."
  type        = string
}

variable "network_compartment_id" {
  default     = ""
  description = "The compartment id where network resources will be created."
  type        = string
}

# Automatically populated by Resource Manager
variable "region" {
  default = "us-ashburn-1"
  # List of regions: https://docs.cloud.oracle.com/iaas/Content/General/Concepts/regions.htm#ServiceAvailabilityAcrossRegions
  description = "The OCI region where OKE resources will be created."
  type        = string
}

variable "home_region" {
  default = ""
  # List of regions: https://docs.cloud.oracle.com/iaas/Content/General/Concepts/regions.htm#ServiceAvailabilityAcrossRegions
  description = "The tenancy's home region. Required to perform identity operations."
  type        = string
}

variable "api_fingerprint" {
  default     = ""
  description = "Fingerprint of the API private key to use with OCI API."
  type        = string
}

variable "api_private_key" {
  default     = ""
  description = "The contents of the private key file to use with OCI API, optionally base64-encoded. This takes precedence over private_key_path if both are specified in the provider."
  sensitive   = true
  type        = string
}

variable "api_private_key_password" {
  default     = ""
  description = "The corresponding private key password to use with the api private key if it is encrypted."
  sensitive   = true
  type        = string
}

variable "api_private_key_path" {
  default     = ""
  description = "The path to the OCI API private key."
  type        = string
}

variable "config_file_profile" {
  default     = "DEFAULT"
  description = "The profile within the OCI config file to use."
  type        = string
}

variable "create_policies" {
  default     = true
  description = "Whether to create Dynamic Group and Policy IAM resources for extra permissions."
  type        = bool
}

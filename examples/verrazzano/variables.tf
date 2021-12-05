# Copyright 2017, 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# OCI Provider parameters
variable "api_fingerprint" {
  default     = ""
  description = "Fingerprint of the API private key to use with OCI API."
  type        = string
}

variable "api_private_key_path" {
  default     = ""
  description = "The path to the OCI API private key."
  type        = string
}

variable "verrazzano_regions" {
  # List of regions: https://docs.cloud.oracle.com/iaas/Content/General/Concepts/regions.htm#ServiceAvailabilityAcrossRegions
  description = "A map Verrazzano regions."
  type        = map(string)
}

variable "tenancy_id" {
  description = "The tenancy id of the OCI Cloud Account in which to create the resources."
  type        = string
}

variable "user_id" {
  description = "The id of the user that terraform will use to create the resources."
  type        = string
  default     = ""
}

# General OCI parameters
variable "compartment_id" {
  description = "The compartment id where to create all resources."
  type        = string
}

variable "label_prefix" {
  default     = "none"
  description = "A string that will be prepended to all resources."
  type        = string
}

# ssh keys
variable "ssh_private_key_path" {
  default     = "none"
  description = "The path to ssh private key."
  type        = string
}

variable "ssh_public_key_path" {
  default     = "none"
  description = "The path to ssh public key."
  type        = string
}

# Verrrazzano parameters

variable "verrazzano_version" {
  default     = "1.0.3"
  description = "Version of Verrazzano release to install"
  type        = string
}

variable "verrazzano_name" {
  default     = "v8o"
  description = "Name of Verrazzano resource"
  type        = string
}

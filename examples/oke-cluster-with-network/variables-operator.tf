# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

variable "create_operator" { default = true }
variable "operator_install_helm" { default = true }
variable "operator_install_k9s" { default = false }
variable "operator_install_kubectx" { default = true }
variable "operator_pv_transit_encryption" { default = false }
variable "operator_upgrade" { default = false }
variable "operator_availability_domain" {
  default = null
  type    = string
}
variable "operator_cloud_init" {
  default = []
  type    = list(map(string))
}

variable "operator_user" { default = "opc" }
variable "operator_image_id" {
  default = null
  type    = string
}
variable "operator_image_os" { default = "Oracle Linux" }
variable "operator_image_os_version" { default = "8" }
variable "operator_image_type" {
  default = "Platform"
  type    = string
  validation {
    condition     = contains(["custom", "platform"], lower(var.operator_image_type))
    error_message = "Accepted values are custom or platform"
  }
}
variable "operator_shape" {
  default = {
    shape            = "VM.Standard.E4.Flex",
    ocpus            = 1,
    memory           = 4,
    boot_volume_size = 50
  }
  type = map(any)
}
variable "operator_volume_kms_vault_id" {
  default = null
  type    = string
}
variable "operator_volume_kms_key_id" {
  default = null
  type    = string
}
variable "operator_private_ip" {
  default = null
  type    = string
}
variable "operator_tags" {
  default = {}
  type    = map(any)
}

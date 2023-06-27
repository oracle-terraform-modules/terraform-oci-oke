# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

variable "create_bastion" { default = true }
variable "bastion_is_public" { default = true }
variable "bastion_upgrade" { default = false }

variable "bastion_allowed_cidrs" {
  default = "0.0.0.0/0"
  type    = string
}

variable "bastion_availability_domain" {
  default = null
  type    = string
}

variable "bastion_user" {
  default = "opc"
  type    = string
}

variable "bastion_image_id" {
  default = null
  type    = string
}

variable "bastion_image_type" {
  default = "platform"
  type    = string
  validation {
    condition     = contains(["custom", "platform"], lower(var.bastion_image_type))
    error_message = "Accepted values are custom or platform"
  }
}

variable "bastion_image_os" {
  default = "Oracle Autonomous Linux"
  type    = string
}

variable "bastion_image_os_version" {
  default = "8.7"
  type    = string
}

variable "bastion_shape" {
  default = {
    shape            = "VM.Standard.E4.Flex",
    ocpus            = 1,
    memory           = 4,
    boot_volume_size = 50
  }
  type = map(any)
}

variable "bastion_tags" {
  default = {}
  type    = map(any)
}

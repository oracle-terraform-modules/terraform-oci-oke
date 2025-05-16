# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

variable "create_bastion" {
  default     = true
  description = "Whether to create a bastion host."
  type        = bool
}

variable "bastion_public_ip" {
  default     = null
  description = "The IP address of an existing bastion host, if create_bastion = false."
  type        = string
}

variable "bastion_allowed_cidrs" {
  default     = []
  description = "A list of CIDR blocks to allow SSH access to the bastion host. NOTE: Default is empty i.e. no access permitted. Allow access from anywhere with '0.0.0.0/0'."
  type        = list(string)
}

variable "bastion_availability_domain" {
  default     = null
  description = "The availability domain for bastion placement. Defaults to first available."
  type        = string
}

variable "bastion_nsg_ids" {
  description = "An additional list of network security group (NSG) IDs for bastion security."
  default     = []
  type        = list(string)
}

variable "bastion_user" {
  default     = "opc"
  description = "User for SSH access through bastion host."
  type        = string
}

variable "bastion_image_id" {
  default     = null
  description = "Image ID for created bastion instance."
  type        = string
}

variable "bastion_image_type" {
  default     = "platform"
  description = "Whether to use a platform or custom image for the created bastion instance. When custom is set, the bastion_image_id must be specified."
  type        = string
  validation {
    condition     = contains(["custom", "platform"], var.bastion_image_type)
    error_message = "Accepted values are custom or platform"
  }
}

variable "bastion_image_os" {
  default     = "Oracle Autonomous Linux"
  description = "Bastion image operating system name when bastion_image_type = 'platform'."
  type        = string
}

variable "bastion_image_os_version" {
  default     = "8"
  description = "Bastion image operating system version when bastion_image_type = 'platform'."
  type        = string
}

variable "bastion_shape" {
  default = {
    shape            = "VM.Standard.E4.Flex",
    ocpus            = 1,
    memory           = 4,
    boot_volume_size = 50
  }
  description = "The shape of bastion instance."
  type        = map(any)
}

variable "bastion_is_public" {
  default     = true
  description = "Whether to create allocate a public IP and subnet for the created bastion host."
  type        = bool
}

variable "bastion_upgrade" {
  default     = false
  description = "Whether to upgrade bastion packages after provisioning."
  type        = bool
}

variable "bastion_await_cloudinit" {
  default     = true
  description = "Whether to block until successful connection to bastion and completion of cloud-init."
  type        = bool
}
# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  # SSH key precedence: base64-encoded PEM > raw PEM > file PEM > null
  ssh_key_arg = coalesce(var.ssh_private_key_path, "none") != "none" ? " -i ${var.ssh_private_key_path}" : ""
  ssh_private_key = (
    coalesce(var.ssh_private_key, "none") != "none"
    ? try(base64decode(var.ssh_private_key), var.ssh_private_key)
    : coalesce(var.ssh_private_key_path, "none") != "none" ? file(var.ssh_private_key_path) : null
  )
  ssh_public_key = (
    coalesce(var.ssh_public_key, "none") != "none"
    ? try(base64decode(var.ssh_public_key), var.ssh_public_key)
    : coalesce(var.ssh_public_key_path, "none") != "none" ? file(var.ssh_public_key_path) : null
  )
}

variable "ssh_private_key" {
  default     = ""
  description = "The contents of the private ssh key file, optionally base64-encoded."
  sensitive   = true
  type        = string
}

variable "ssh_private_key_path" {
  default     = "none"
  description = "The path to ssh private key."
  type        = string
}

variable "ssh_public_key" {
  default     = ""
  description = "The contents of the ssh public key."
  type        = string
}

variable "ssh_public_key_path" {
  default     = "none"
  description = "The path to ssh public key."
  type        = string
}

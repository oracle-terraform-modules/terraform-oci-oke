# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
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

variable "output_detail" {
  default     = false
  description = "Whether to include detailed output in state."
  type        = bool
}

variable "timezone" {
  default     = "Etc/UTC"
  description = "The preferred timezone for the worker nodes."
  type        = string
}

variable "ssh_private_key" {
  default     = ""
  description = "The contents of the SSH private key file, optionally base64-encoded. May be provided via SSH agent when unset."
  sensitive   = true
  type        = string
}

variable "ssh_private_key_path" {
  default     = "none"
  description = "A path on the local filesystem to the SSH private key. May be provided via SSH agent when unset."
  type        = string
}

variable "ssh_public_key" {
  default     = ""
  description = "The contents of the SSH public key file, optionally base64-encoded. Used to allow login for workers/bastion/operator with corresponding private key."
  type        = string
}

variable "ssh_public_key_path" {
  default     = "none"
  description = "A path on the local filesystem to the SSH public key. Used to allow login for workers/bastion/operator with corresponding private key."
  type        = string
}

# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  ssh_public_key = try(base64decode(var.ssh_public_key), var.ssh_public_key)
}

# General

variable "output_detail" { default = false }
variable "timezone" { default = "Etc/UTC" }

# SSH

variable "ssh_public_key" {
  default = null
  type    = string
}
variable "ssh_kms_vault_id" {
  default = null
  type    = string
}
variable "ssh_kms_secret_id" {
  default = null
  type    = string
}

# Oracle Container Image Registry (OCIR)

variable "ocir_email_address" {
  default = null
  type    = string
}
variable "ocir_kms_vault_id" {
  default = null
  type    = string
}
variable "ocir_kms_secret_id" {
  default = null
  type    = string
}
variable "ocir_secret_name" { default = "ocirsecret" }
variable "ocir_secret_namespace" { default = "default" }
variable "ocir_username" {
  default = null
  type    = string
}

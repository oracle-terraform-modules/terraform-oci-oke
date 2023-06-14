# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

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

data "oci_identity_region_subscriptions" "home" {
  tenancy_id = var.tenancy_ocid
  filter {
    name   = "is_home_region"
    values = [true]
  }
}

data "oci_secrets_secretbundle" "ssh_key" {
  secret_id = var.ssh_kms_secret_id
}

locals {
  ssh_public_key         = try(base64decode(var.ssh_public_key), var.ssh_public_key)
  ssh_key_bundle         = sensitive(one(data.oci_secrets_secretbundle.ssh_key.secret_bundle_content))
  ssh_key_bundle_content = sensitive(lookup(local.ssh_key_bundle, "content", null))
}

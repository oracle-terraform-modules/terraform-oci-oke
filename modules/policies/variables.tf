# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Identity and access parameters

variable "oci_identity" {
  type = object({
    api_fingerprint      = string
    api_private_key_path = string
    compartment_id       = string
    tenancy_id           = string
    user_id              = string
  })
}

# ssh keys

variable "ssh_keys" {
  type = object({
    ssh_private_key_path = string
    ssh_public_key_path  = string
  })
}


variable "label_prefix" {}

variable "admin" {
  type = object({
    bastion_public_ip               = string
    admin_private_ip                = string
    bastion_enabled                  = bool
    admin_enabled                    = bool
    admin_instance_principal = bool
  })
}

variable "dynamic_group" {
  description = "name of dynamic group to allow updating dynamic-groups"
  type        = string
}

variable "oke_kms" {
  type = object({
    use_encryption = bool
    key_id         = string
  })
}

variable "cluster_id" {}

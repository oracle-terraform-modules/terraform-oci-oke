# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# general oci
variable "compartment_id" {}

variable "label_prefix" {}

# provider
variable "api_fingerprint" {}

variable "api_private_key_path" {}

variable "region" {}

variable "tenancy_id" {}

variable "user_id" {}

# ssh keys
variable "ssh_keys" {
  type = object({
    ssh_private_key_path = string
    ssh_public_key_path  = string
  })
}

variable "operator" {
  type = object({
    bastion_public_ip           = string
    operator_private_ip         = string
    bastion_enabled             = bool
    operator_enabled            = bool
    operator_instance_principal = bool
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

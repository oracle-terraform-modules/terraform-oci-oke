# Copyright 2017, 2021 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# general oci
variable "compartment_id" {}

variable "label_prefix" {}

# provider

variable "tenancy_id" {}

# ssh keys
variable "ssh_private_key_path" {}

variable "ssh_public_key_path" {}

# bastion and operator details
variable "bastion_public_ip" {}

variable "operator_private_ip" {}

variable "bastion_enabled" {
  type = bool
}
variable "operator_enabled" {
  type = bool
}
variable "operator_instance_principal" {
  type = bool
}

variable "bastion_state" {}

variable "dynamic_group" {
  description = "name of dynamic group to allow updating dynamic-groups"
  type        = string
}

variable "use_encryption" {}

variable "key_id" {}

variable "cluster_id" {}

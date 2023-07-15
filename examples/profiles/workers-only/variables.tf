# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

variable "tenancy_id" { type = string }
variable "compartment_id" { type = string }
variable "region" { type = string }
variable "vcn_id" { type = string }
variable "bastion_public_ip" { type = string }
variable "cluster_id" { type = string }
variable "worker_subnet_id" { type = string }

variable "config_file_profile" {
  default = "DEFAULT"
  type    = string
}

variable "operator_private_ip" {
  default = null
  type    = string
}

variable "worker_nsg_ids" {
  default = []
  type    = list(string)
}

variable "ssh_public_key_path" {
  default = null
  type    = string
}

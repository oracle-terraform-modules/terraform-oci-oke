# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "user_ocid" {}

variable tenancy_ocid {}

variable "api_fingerprint" {}

variable "api_private_key_path" {}

variable "ssh_private_key_path" {}
variable "ssh_public_key_path" {}

variable "compartment_ocid" {}

variable "compartment_name" {}
variable "vcn_id" {}

variable "region" {}

variable "label_prefix" {}

variable preferred_bastion_image {}
variable image_ocid {}

variable "ad_names" {
  type = "list"
}

variable "availability_domains" {
  type = "map"
}

variable bastion_shape {}

variable "bastion_subnet_ids" {
  type = "map"
}

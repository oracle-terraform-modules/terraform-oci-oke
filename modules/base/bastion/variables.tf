# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

# identity

variable "api_fingerprint" {}

variable "api_private_key_path" {}

variable "compartment_ocid" {}

# general
variable "label_prefix" {}

variable "region" {}

# ssh
variable "ssh_private_key_path" {}

variable "ssh_public_key_path" {}

# bastion
variable "bastion_shape" {}

variable "create_bastion" {}

variable "image_ocid" {}

variable "image_operating_system" {}

variable "image_operating_system_version" {}



# kubeconfig
variable "config_output_path" {
  type        = "string"
  description = "output path for configuration files"
}

# networking
variable "ig_route_id" {}

variable "newbits" {
  type = "map"
}

variable "subnets" {
  type = "map"
}

variable "vcn_cidr" {}

variable "vcn_id" {}

# ad

variable "ad_names" {
  type = "list"
}

variable "availability_domains" {
  type = "map"
}

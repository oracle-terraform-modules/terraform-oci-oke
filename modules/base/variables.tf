# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "tenancy_ocid" {}

variable "user_ocid" {}

variable "compartment_ocid" {}

variable "compartment_name" {}
variable "api_fingerprint" {}

variable "api_private_key_path" {}

variable "ssh_private_key_path" {}
variable "ssh_public_key_path" {}

variable "enable_instance_principal" {}
variable "region" {}

variable "disable_auto_retries" {
  default = "true"
}

variable "label_prefix" {}

variable "vcn_dns_name" {}

variable "vcn_name" {}

variable "vcn_cidr" {}

variable "newbits" {
  type = "map"
}

variable "subnets" {
  type        = "map"
}

variable "preferred_bastion_image" {}
variable "imageocids" {
  type = "map"
}

variable "bastion_shape" {}

variable "availability_domains" {
  type        = "map"
}

variable "create_nat_gateway" {}

variable "nat_gateway_name" {}

variable "create_service_gateway" {}

variable "service_gateway_name" {}

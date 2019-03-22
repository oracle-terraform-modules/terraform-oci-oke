# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "tenancy_ocid" {}

variable "compartment_ocid" {}

variable "vcn_name" {}

variable "vcn_dns_name" {}

variable "label_prefix" {}

variable "vcn_cidr" {}

variable "newbits" {
  type = "map"
}

variable "subnets" {
  type        = "map"
}

variable "ad_names" {
  type = "list"
}
variable "availability_domains" {
  type        = "map"
}

variable "create_nat_gateway" {}

variable "nat_gateway_name" {}

variable "create_service_gateway" {}

variable "service_gateway_name" {}

variable "service_gateway_state" {
  default = "AVAILABLE"
}

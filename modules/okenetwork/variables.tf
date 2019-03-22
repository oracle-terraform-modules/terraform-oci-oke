# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "compartment_ocid" {}

variable "tenancy_ocid" {}

variable "label_prefix" {}

variable "vcn_id" {}

variable "ig_route_id" {}

variable "subnets" {
  type = "map"
}

variable "vcn_cidr" {}

variable "newbits" {
  type = "map"
}

variable "ad_names" {
  type = "list"
}

variable "availability_domains" {
  type = "map"
}

variable "worker_mode" {}

variable "nat_route_id" {}

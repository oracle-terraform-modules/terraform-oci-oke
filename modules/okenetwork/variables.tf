# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

# Identity and access parameters

variable "compartment_ocid" {}

variable "tenancy_ocid" {}

# general oci parameters

variable "ad_names" {
  type = "list"
}
variable "label_prefix" {}

variable "region" {}

# networking parameters

variable "ig_route_id" {}

variable "is_service_gateway_enabled" {}

variable "nat_route_id" {}

variable "newbits" {
  type = "map"
}

variable "subnets" {
  type = "map"
}

variable "vcn_cidr" {}

variable "vcn_id" {}

# availability domains

variable "availability_domains" {
  type = "map"
}

# oke

variable "allow_node_port_access" {}

variable "allow_worker_ssh_access" {}

variable "worker_mode" {}

# load balancers

variable "load_balancer_subnet_type" {}

variable "preferred_load_balancer_subnets" {}
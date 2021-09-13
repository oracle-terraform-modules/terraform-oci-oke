# Copyright 2017, 2021 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# general oci parameters
variable "compartment_id" {}

variable "label_prefix" {}

# networking parameters
variable "ig_route_id" {}

variable "nat_route_id" {}

variable "subnets" {
  type = map(any)
}

variable "vcn_id" {}

# cluster endpoint

variable "control_plane_access" {
  type = string
}

variable "control_plane_access_source" {
  type = list(string)
}

# oke workers

variable "allow_node_port_access" {
  type = bool
}

variable "allow_worker_internet_access" {
  type = bool
}

variable "allow_worker_ssh_access" {
  type = bool
}

variable "worker_mode" {}

# load balancers

variable "lb_subnet_type" {
  type = string
}

variable "public_lb_ports" {
  type = list(number)
}

variable "enable_waf" {
  type = bool
}


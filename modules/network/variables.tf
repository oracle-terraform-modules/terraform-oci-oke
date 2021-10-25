# Copyright 2017, 2021 Oracle Corporation and/or affiliates.
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

variable "control_plane_type" {
  type = string
}

variable "control_plane_allowed_cidrs" {
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

variable "worker_type" {}

# load balancers

variable "enable_waf" {
  type = bool
}

variable "load_balancers" {
  type = string
}

# internal load balancers
variable "internal_lb_allowed_cidrs" {
  type = list(any)
}

variable "internal_lb_allowed_ports" {
  type = list(any)
}

# public load balancers
variable "public_lb_allowed_cidrs" {
  type = list(any)
}

variable "public_lb_allowed_ports" {
  type = list(any)
}




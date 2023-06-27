# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

variable "create_vcn" { default = true }
variable "assign_dns" { default = true }
variable "control_plane_is_public" { default = false }
variable "enable_waf" { default = false }
variable "worker_is_public" { default = false }

variable "vcn_name" {
  default = null
  type    = string
}

variable "vcn_id" {
  default = null
  type    = string
}

variable "vcn_create_nat_gateway" {
  default = true
  type    = bool
}

variable "vcn_create_internet_gateway" {
  default = true
  type    = bool
}

variable "vcn_create_service_gateway" {
  default = true
  type    = bool
}

variable "ig_route_table_id" {
  default = null
  type    = string
}

variable "create_drg" { default = false }

variable "drg_display_name" {
  default = null
  type    = string
}

variable "drg_id" {
  default = null
  type    = string
}

variable "internet_gateway_route_rules" {
  default = null
  type    = list(map(string))
}

variable "local_peering_gateways" {
  default = null
  type    = map(any)
}

variable "lockdown_default_seclist" { default = true }

variable "nat_gateway_route_rules" {
  default = null
  type    = list(map(string))
}

variable "vcn_cidrs" {
  default = "10.0.0.0/16"
  type    = string
}

variable "vcn_dns_label" {
  default = null
  type    = string
}

variable "load_balancers" {
  default = "Internal"
  type    = string
}

variable "preferred_load_balancer" {
  default = "Internal"
  type    = string
}

variable "create_nsgs" { default = true }
variable "allow_node_port_access" { default = false }
variable "allow_pod_internet_access" { default = true }
variable "allow_worker_internet_access" { default = true }
variable "allow_worker_ssh_access" { default = false }

variable "allow_rules_internal_lb" {
  default = {}
  type    = any
}

variable "allow_rules_public_lb" {
  default = {}
  type    = any
}

variable "control_plane_allowed_cidrs" {
  default = ""
  type    = string
}

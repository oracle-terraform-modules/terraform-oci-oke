# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

variable "create_vcn" { default = true }

variable "vcn_name" {
  default = null
  type    = string
}

variable "vcn_id" {
  default = null
  type    = string
}

variable "vcn_create_nat_gateway" { default = "Auto" }
variable "vcn_create_internet_gateway" { default = "Auto" }
variable "vcn_create_service_gateway" { default = "Always" }
variable "ig_route_table_id" {
  default = null
  type    = string
}
variable "service_gateway_id" {
  default = null
  type    = string
}
variable "nat_gateway_id" {
  default = null
  type    = string
}
variable "nat_route_table_id" {
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
variable "nat_gateway_public_ip_id" {
  default = null
  type    = string
}

variable "vcn_cidrs" { default = "10.0.0.0/16" }
variable "vcn_dns_label" {
  default = null
  type    = string
}

variable "assign_dns" { default = true }
variable "control_plane_is_public" { default = false }
variable "enable_waf" { default = false }
variable "worker_is_public" { default = false }

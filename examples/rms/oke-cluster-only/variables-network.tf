# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

variable "vcn_id" { type = string }
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
variable "assign_dns" { default = true }
variable "control_plane_is_public" { default = false }
variable "control_plane_nsg_id" { default = "" }
variable "operator_nsg_id" { default = "" }

variable "control_plane_subnet_id" {
  type = string
}
variable "int_lb_subnet_id" {
  type    = string
  default = null
}
variable "operator_subnet_id" {
  type    = string
  default = null
}
variable "pub_lb_subnet_id" {
  type    = string
  default = null
}

variable "bastion_public_ip" {
  default = null
  type    = string
}

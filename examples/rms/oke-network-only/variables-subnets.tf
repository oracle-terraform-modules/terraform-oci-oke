# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

variable "bastion_subnet_create" { default = true }
variable "control_plane_subnet_create" { default = true }
variable "int_lb_subnet_create" { default = true }
variable "operator_subnet_create" { default = true }
variable "pod_subnet_create" { default = true }
variable "pub_lb_subnet_create" { default = true }
variable "worker_subnet_create" { default = true }

variable "bastion_subnet_newbits" { default = 13 }
variable "control_plane_subnet_newbits" { default = 13 }
variable "int_lb_subnet_newbits" { default = 11 }
variable "operator_subnet_newbits" { default = 13 }
variable "pod_subnet_newbits" { default = 2 }
variable "pub_lb_subnet_newbits" { default = 11 }
variable "worker_subnet_newbits" { default = 2 }

variable "bastion_subnet_id" {
  type    = string
  default = null
}
variable "control_plane_subnet_id" {
  type    = string
  default = null
}
variable "int_lb_subnet_id" {
  type    = string
  default = null
}
variable "operator_subnet_id" {
  type    = string
  default = null
}
variable "pod_subnet_id" {
  type    = string
  default = null
}
variable "pub_lb_subnet_id" {
  type    = string
  default = null
}
variable "worker_subnet_id" {
  type    = string
  default = null
}

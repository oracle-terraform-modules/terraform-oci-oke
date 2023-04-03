# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

variable "bastion_subnet_create" { default = "Auto" }
variable "operator_subnet_create" { default = "Auto" }
variable "control_plane_subnet_create" { default = "Auto" }
variable "int_lb_subnet_create" { default = "Auto" }
variable "pub_lb_subnet_create" { default = "Auto" }
variable "worker_subnet_create" { default = "Auto" }
variable "pod_subnet_create" { default = "Auto" }
variable "fss_subnet_create" { default = "Auto" }

variable "bastion_subnet_newbits" { default = 13 }
variable "control_plane_subnet_newbits" { default = 13 }
variable "fss_subnet_newbits" { default = 11 }
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
variable "fss_subnet_id" {
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

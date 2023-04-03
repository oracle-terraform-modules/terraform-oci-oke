# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

variable "create_nsgs" { default = true }
variable "allow_node_port_access" { default = false }
variable "allow_pod_internet_access" { default = true }
variable "allow_worker_internet_access" { default = true }
variable "allow_worker_ssh_access" { default = false }
variable "bastion_nsg_id" { default = "" }
variable "control_plane_allowed_cidrs" { default = "" }
variable "control_plane_nsg_id" { default = "" }
variable "fss_nsg_id" { default = "" }
variable "operator_nsg_id" { default = "" }
variable "pod_nsg_id" { default = "" }
variable "worker_nsg_id" { default = "" }

variable "allow_rules_internal_lb" {
  default = {}
  type    = any
}

variable "allow_rules_public_lb" {
  default = {}
  type    = any
}

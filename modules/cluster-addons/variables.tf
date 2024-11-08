# Copyright (c) 2017, 2024 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# General variables
variable "cluster_id" { type = string }
variable "cluster_addons" { type = any }
variable "cluster_addons_to_remove" { type = any }
variable "kubernetes_version" { type = string }

# Variables required to access the operator host
variable "bastion_host" { type = string }
variable "bastion_user" { type = string }
variable "operator_enabled" { type = bool }
variable "operator_host" { type = string }
variable "operator_user" { type = string }
variable "ssh_private_key" { type = string }


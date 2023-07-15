# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Common
variable "region" { type = string }
variable "worker_pools" { type = any }

# Connection
variable "bastion_host" { type = string }
variable "bastion_user" { type = string }
variable "operator_host" { type = string }
variable "operator_user" { type = string }
variable "ssh_private_key" {
  type      = string
  sensitive = true
}

# OCIR
variable "ocir_email_address" { type = string }
variable "ocir_secret_id" { type = string }
variable "ocir_secret_name" { type = string }
variable "ocir_secret_namespace" { type = string }
variable "ocir_username" { type = string }

# Node readiness check, drain
variable "await_node_readiness" { type = string }
variable "expected_drain_count" { type = number }
variable "expected_node_count" { type = number }
variable "worker_drain_ignore_daemonsets" { type = bool }
variable "worker_drain_delete_local_data" { type = bool }
variable "worker_drain_timeout_seconds" { type = number }

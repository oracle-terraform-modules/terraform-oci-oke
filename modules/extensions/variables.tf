# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Common
variable "compartment_id" { type = string }
variable "region" { type = string }

# Connection
variable "bastion_public_ip" { type = string }
variable "bastion_user" { type = string }
variable "operator_private_ip" { type = string }
variable "operator_user" { type = string }
variable "ssh_private_key" { type = string }

# Cluster
variable "cluster_id" { type = string }
variable "cni_type" { type = string }

# Calico
variable "calico_apiserver_enabled" { type = bool }
variable "calico_mode" { type = string }
variable "calico_mtu" { type = number }
variable "calico_staging_dir" { type = string }
variable "calico_url" { type = string }
variable "calico_version" { type = string }
variable "enable_calico" { type = bool }
variable "pods_cidr" { type = string }
variable "typha_enabled" { type = bool }
variable "typha_replicas" { type = number }

# Gatekeeper
variable "enable_gatekeeper" { type = bool }
variable "gatekeeper_version" { type = string }

# Service account
variable "create_service_account" { type = bool }
variable "service_account_cluster_role_binding" { type = string }
variable "service_account_name" { type = string }
variable "service_account_namespace" { type = string }

# OCIR
variable "email_address" { type = string }
variable "secret_id" { type = string }
variable "secret_name" { type = string }
variable "secret_namespace" { type = string }
variable "username" { type = string }

# Node readiness check
variable "await_node_readiness" { type = string }
variable "expected_node_count" { type = number }

# Metrics server
variable "enable_metric_server" { type = bool }
variable "enable_vpa" { type = bool }
variable "vpa_version" { type = string }

# Worker draining
# TODO move to workers
variable "node_pools_to_drain" { type = list(string) }
variable "upgrade_nodepool" { type = bool }

# Cluster autoscaler
variable "deploy_cluster_autoscaler" { type = bool }
variable "autoscaling_groups" { type = any }

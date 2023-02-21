# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Common
variable "region" { type = string }
variable "worker_pools" { type = any }
variable "kubernetes_version" { type = string }
variable "expected_node_count" { type = number }

# Connection
variable "bastion_host" { type = string }
variable "bastion_user" { type = string }
variable "operator_host" { type = string }
variable "operator_user" { type = string }
variable "ssh_private_key" { type = string }

# Calico
variable "calico_apiserver_enabled" { type = bool }
variable "calico_enabled" { type = bool }
variable "calico_mode" { type = string }
variable "calico_mtu" { type = number }
variable "calico_staging_dir" { type = string }
variable "calico_typha_enabled" { type = bool }
variable "calico_typha_replicas" { type = number }
variable "calico_url" { type = string }
variable "calico_version" { type = string }
variable "cni_type" { type = string }
variable "pods_cidr" { type = string }

# Metrics server
variable "metrics_server_enabled" { type = bool }
variable "metrics_server_namespace" { type = string }
variable "metrics_server_helm_version" { type = string }
variable "metrics_server_helm_values" { type = map(string) }
variable "metrics_server_helm_values_files" { type = list(string) }

# Cluster autoscaler
variable "cluster_autoscaler_enabled" { type = bool }
variable "cluster_autoscaler_namespace" { type = string }
variable "cluster_autoscaler_helm_version" { type = string }
variable "cluster_autoscaler_helm_values" { type = map(string) }
variable "cluster_autoscaler_helm_values_files" { type = list(string) }

# Prometheus
variable "prometheus_enabled" { type = bool }
variable "prometheus_namespace" { type = string }
variable "prometheus_helm_version" { type = string }
variable "prometheus_helm_values" { type = map(string) }
variable "prometheus_helm_values_files" { type = list(string) }

# Gatekeeper
variable "gatekeeper_enabled" { type = bool }
variable "gatekeeper_namespace" { type = string }
variable "gatekeeper_helm_version" { type = string }
variable "gatekeeper_helm_values" { type = map(string) }
variable "gatekeeper_helm_values_files" { type = list(string) }

# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Common
variable "region" { type = string }
variable "state_id" { type = string }
variable "worker_pools" { type = any }
variable "kubernetes_version" { type = string }
variable "expected_node_count" { type = number }
variable "cluster_private_endpoint" { type = string }

# Connection
variable "bastion_host" { type = string }
variable "bastion_user" { type = string }
variable "operator_host" { type = string }
variable "operator_user" { type = string }
variable "ssh_private_key" { type = string }

# CNI
variable "vcn_cidrs" { type = list(string) }
variable "cni_type" { type = string }
variable "pods_cidr" { type = string }

# CNI: Cilium
variable "cilium_install" { type = bool }
variable "cilium_reapply" { type = bool }
variable "cilium_namespace" { type = string }
variable "cilium_helm_version" { type = string }
variable "cilium_helm_values" { type = any }
variable "cilium_helm_values_files" { type = list(string) }

# CNI: Multus
variable "multus_install" { type = bool }
variable "multus_namespace" { type = string }
variable "multus_daemonset_url" { type = string }
variable "multus_version" { type = string }

# SR-IOV Device Plugin
variable "sriov_device_plugin_install" { type = bool }
variable "sriov_device_plugin_namespace" { type = string }
variable "sriov_device_plugin_daemonset_url" { type = string }
variable "sriov_device_plugin_version" { type = string }

# SR-IOV CNI Plugin
variable "sriov_cni_plugin_install" { type = bool }
variable "sriov_cni_plugin_namespace" { type = string }
variable "sriov_cni_plugin_daemonset_url" { type = string }
variable "sriov_cni_plugin_version" { type = string }

# RDMA CNI Plugin
variable "rdma_cni_plugin_install" { type = bool }
variable "rdma_cni_plugin_namespace" { type = string }
variable "rdma_cni_plugin_daemonset_url" { type = string }
variable "rdma_cni_plugin_version" { type = string }

# Whereabouts
variable "whereabouts_install" { type = bool }
variable "whereabouts_namespace" { type = string }
variable "whereabouts_daemonset_url" { type = string }
variable "whereabouts_version" { type = string }

# Metrics server
variable "metrics_server_install" { type = bool }
variable "metrics_server_namespace" { type = string }
variable "metrics_server_helm_version" { type = string }
variable "metrics_server_helm_values" { type = map(string) }
variable "metrics_server_helm_values_files" { type = list(string) }

# Cluster autoscaler
variable "cluster_autoscaler_install" { type = bool }
variable "cluster_autoscaler_namespace" { type = string }
variable "cluster_autoscaler_helm_version" { type = string }
variable "cluster_autoscaler_helm_values" { type = map(string) }
variable "cluster_autoscaler_helm_values_files" { type = list(string) }
variable "expected_autoscale_worker_pools" { type = number }

# Prometheus
variable "prometheus_install" { type = bool }
variable "prometheus_reapply" { type = bool }
variable "prometheus_namespace" { type = string }
variable "prometheus_helm_version" { type = string }
variable "prometheus_helm_values" { type = map(string) }
variable "prometheus_helm_values_files" { type = list(string) }

# DCGM exporter
variable "dcgm_exporter_install" { type = bool }
variable "dcgm_exporter_reapply" { type = bool }
variable "dcgm_exporter_namespace" { type = string }
variable "dcgm_exporter_helm_version" { type = string }
variable "dcgm_exporter_helm_values" { type = map(string) }
variable "dcgm_exporter_helm_values_files" { type = list(string) }

# MPI Operator
variable "mpi_operator_install" { type = bool }
variable "mpi_operator_namespace" { type = string }
variable "mpi_operator_deployment_url" { type = string }
variable "mpi_operator_version" { type = string }

# Gatekeeper
variable "gatekeeper_install" { type = bool }
variable "gatekeeper_namespace" { type = string }
variable "gatekeeper_helm_version" { type = string }
variable "gatekeeper_helm_values" { type = map(string) }
variable "gatekeeper_helm_values_files" { type = list(string) }

# Service Account
variable "create_service_account" { type = bool }
variable "service_accounts" { type = map(any) }
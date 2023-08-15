# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# CNI: Multus

variable "multus_install" { default = false }
variable "multus_namespace" { default = "network" }
variable "multus_daemonset_url" {
  default = null
  type    = string
}
variable "multus_version" { default = "master" }

# Metrics server

variable "metrics_server_install" { default = false }
variable "metrics_server_namespace" { default = "metrics" }
variable "metrics_server_helm_version" { default = "3.8.3" }
variable "metrics_server_helm_values" {
  default = {}
  type    = map(string)
}
variable "metrics_server_helm_values_files" {
  default = []
  type    = list(string)
}

# Cluster autoscaler

variable "cluster_autoscaler_install" { default = false }
variable "cluster_autoscaler_namespace" { default = "kube-system" }
variable "cluster_autoscaler_helm_version" { default = "9.24.0" }
variable "cluster_autoscaler_helm_values" {
  default = {}
  type    = map(string)
}
variable "cluster_autoscaler_helm_values_files" {
  default = []
  type    = list(string)
}

# Prometheus

variable "prometheus_install" { default = false }
variable "prometheus_reapply" { default = false }
variable "prometheus_namespace" { default = "metrics" }
variable "prometheus_helm_version" { default = "45.2.0" }
variable "prometheus_helm_values" {
  default = {}
  type    = map(string)
}
variable "prometheus_helm_values_files" {
  default = []
  type    = list(string)
}

# DCGM exporter

variable "dcgm_exporter_install" { default = false }
variable "dcgm_exporter_reapply" { default = false }
variable "dcgm_exporter_namespace" { default = "metrics" }
variable "dcgm_exporter_helm_version" { default = "3.1.5" }

# SR-IOV device plugin

variable "sriov_device_plugin_install" { default = false }
variable "sriov_device_plugin_install_config" { default = false }
variable "sriov_device_plugin_namespace" { default = "network" }
variable "sriov_device_plugin_daemonset_url" {
  default = null
  type    = string
}
variable "sriov_device_plugin_version" { default = "master" }

# SR-IOV CNI plugin

variable "sriov_cni_plugin_install" { default = false }
variable "sriov_cni_plugin_namespace" { default = "network" }
variable "sriov_cni_plugin_daemonset_url" {
  default = null
  type    = string
}
variable "sriov_cni_plugin_version" { default = "master" }

# RDMA CNI plugin

variable "rdma_cni_plugin_install" { default = false }
variable "rdma_cni_plugin_namespace" { default = "network" }
variable "rdma_cni_plugin_daemonset_url" {
  default = null
  type    = string
}
variable "rdma_cni_plugin_version" { default = "master" }

# MPI operator

variable "mpi_operator_install" { default = false }
variable "mpi_operator_namespace" { default = "default" }
variable "mpi_operator_deployment_url" {
  default = null
  type    = string
}
variable "mpi_operator_version" { default = "0.4.0" }

# Whereabouts

variable "whereabouts_install" { default = false }
variable "whereabouts_namespace" { default = "network" }
variable "whereabouts_daemonset_url" {
  default = null
  type    = string
}
variable "whereabouts_version" { default = "master" }

# Gatekeeper

variable "gatekeeper_install" { default = false }
variable "gatekeeper_namespace" { default = "kube-system" }
variable "gatekeeper_helm_version" { default = "3.11.0" }
variable "gatekeeper_helm_values" {
  default = {}
  type    = map(string)
}
variable "gatekeeper_helm_values_files" {
  default = []
  type    = list(string)
}

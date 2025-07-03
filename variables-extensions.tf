# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# CNI: Cilium

variable "cilium_install" {
  default     = false
  description = "Whether to deploy the Cilium Helm chart. May only be enabled when cni_type = 'flannel'. See https://docs.cilium.io. NOTE: Provided only as a convenience and not supported by or sourced from Oracle - use at your own risk."
  type        = bool
}

variable "cilium_reapply" {
  default     = false
  description = "Whether to force reapply of the chart when no changes are detected, e.g. with state modified externally."
  type        = bool
}

variable "cilium_namespace" {
  default     = "kube-system"
  description = "Kubernetes namespace for deployed resources."
  type        = string
}

variable "cilium_helm_version" {
  default     = "1.16.3"
  description = "Version of the Helm chart to install. List available releases using `helm search repo [keyword] --versions`."
  type        = string
}

variable "cilium_helm_values" {
  default     = {}
  description = "Map of individual Helm chart values. See https://registry.terraform.io/providers/hashicorp/helm/latest/docs/data-sources/template."
  type        = any
}

variable "cilium_helm_values_files" {
  default     = []
  description = "Paths to a local YAML files with Helm chart values (as with `helm install -f` which supports multiple). Generate with defaults using `helm show values [CHART] [flags]`."
  type        = list(string)
}

# CNI: Multus

variable "multus_install" {
  default     = false
  description = "Whether to deploy Multus. See <a href=https://github.com/k8snetworkplumbingwg/multus-cni>k8snetworkplumbingwg/multus-cni</a>. NOTE: Provided only as a convenience and not supported by or sourced from Oracle - use at your own risk."
  type        = bool
}

variable "multus_namespace" {
  default     = "network"
  description = "Kubernetes namespace for deployed resources."
  type        = string
}

variable "multus_daemonset_url" {
  default     = null
  description = "The URL path to the Multus manifest. Leave unset for tags of <a href=https://github.com/k8snetworkplumbingwg/multus-cni>k8snetworkplumbingwg/multus-cni</a> using multus_version."
  type        = string
}

variable "multus_version" {
  default     = "3.9.3"
  description = "Version of Multus to install. Ignored when an explicit value for multus_daemonset_url is provided."
  type        = string
}

# SR-IOV Device Plugin

variable "sriov_device_plugin_install" {
  default     = false
  description = "Whether to deploy the SR-IOV Network Device Plugin. See <a href=https://github.com/k8snetworkplumbingwg/sriov-network-device-plugin>k8snetworkplumbingwg/sriov-network-device-plugin</a>. NOTE: Provided only as a convenience and not supported by or sourced from Oracle - use at your own risk."
  type        = bool
}

variable "sriov_device_plugin_namespace" {
  default     = "network"
  description = "Kubernetes namespace for deployed resources."
  type        = string
}

variable "sriov_device_plugin_daemonset_url" {
  default     = null
  description = "The URL path to the manifest. Leave unset for tags of <a href=https://github.com/k8snetworkplumbingwg/sriov-network-device-plugin>k8snetworkplumbingwg/sriov-network-device-plugin</a> using sriov_device_plugin_version."
  type        = string
}

variable "sriov_device_plugin_version" {
  default     = "master"
  description = "Version to install. Ignored when an explicit value for sriov_device_plugin_daemonset_url is provided."
  type        = string
}

# SR-IOV CNI Plugin

variable "sriov_cni_plugin_install" {
  default     = false
  description = "Whether to deploy the SR-IOV CNI Plugin. See <a href=https://github.com/openshift/sriov-cni</a>. NOTE: Provided only as a convenience and not supported by or sourced from Oracle - use at your own risk."
  type        = bool
}

variable "sriov_cni_plugin_namespace" {
  default     = "network"
  description = "Kubernetes namespace for deployed resources."
  type        = string
}

variable "sriov_cni_plugin_daemonset_url" {
  default     = null
  description = "The URL path to the manifest. Leave unset for tags of <a href=https://github.com/openshift/sriov-cni</a> using sriov_cni_plugin_version."
  type        = string
}

variable "sriov_cni_plugin_version" {
  default     = "master"
  description = "Version to install. Ignored when an explicit value for sriov_cni_plugin_daemonset_url is provided."
  type        = string
}

# RDMA CNI Plugin

variable "rdma_cni_plugin_install" {
  default     = false
  description = "Whether to deploy the SR-IOV CNI Plugin. See <a href=https://github.com/openshift/sriov-cni</a>. NOTE: Provided only as a convenience and not supported by or sourced from Oracle - use at your own risk."
  type        = bool
}

variable "rdma_cni_plugin_namespace" {
  default     = "network"
  description = "Kubernetes namespace for deployed resources."
  type        = string
}

variable "rdma_cni_plugin_daemonset_url" {
  default     = null
  description = "The URL path to the manifest. Leave unset for tags of <a href=https://github.com/openshift/sriov-cni</a> using rdma_cni_plugin_version."
  type        = string
}

variable "rdma_cni_plugin_version" {
  default     = "master"
  description = "Version to install. Ignored when an explicit value for rdma_cni_plugin_daemonset_url is provided."
  type        = string
}

# Metrics server

variable "metrics_server_install" {
  default     = false
  description = "Whether to deploy the Kubernetes Metrics Server Helm chart. See <a href=https://github.com/kubernetes-sigs/metrics-server>kubernetes-sigs/metrics-server</a>. NOTE: Provided only as a convenience and not supported by or sourced from Oracle - use at your own risk."
  type        = bool
}

variable "metrics_server_namespace" {
  default     = "metrics"
  description = "Kubernetes namespace for deployed resources."
  type        = string
}

variable "metrics_server_helm_version" {
  default     = "3.8.3"
  description = "Version of the Helm chart to install. List available releases using `helm search repo [keyword] --versions`."
  type        = string
}

variable "metrics_server_helm_values" {
  default     = {}
  description = "Map of individual Helm chart values. See <a href=https://registry.terraform.io/providers/hashicorp/helm/latest/docs/data-sources/template>data.helm_template</a>."
  type        = map(string)
}

variable "metrics_server_helm_values_files" {
  default     = []
  description = "Paths to a local YAML files with Helm chart values (as with `helm install -f` which supports multiple). Generate with defaults using `helm show values [CHART] [flags]`."
  type        = list(string)
}

# Cluster autoscaler

variable "cluster_autoscaler_install" {
  default     = false
  description = "Whether to deploy the Kubernetes Cluster Autoscaler Helm chart. See <a href=https://github.com/kubernetes/autoscaler>kubernetes/autoscaler</a>. NOTE: Provided only as a convenience and not supported by or sourced from Oracle - use at your own risk."
  type        = bool
}

variable "cluster_autoscaler_namespace" {
  default     = "kube-system"
  description = "Kubernetes namespace for deployed resources."
  type        = string
}

variable "cluster_autoscaler_helm_version" {
  default     = "9.24.0"
  description = "Version of the Helm chart to install. List available releases using `helm search repo [keyword] --versions`."
  type        = string
}

variable "cluster_autoscaler_helm_values" {
  default     = {}
  description = "Map of individual Helm chart values. See <a href=https://registry.terraform.io/providers/hashicorp/helm/latest/docs/data-sources/template>data.helm_template</a>."
  type        = map(string)
}

variable "cluster_autoscaler_helm_values_files" {
  default     = []
  description = "Paths to a local YAML files with Helm chart values (as with `helm install -f` which supports multiple). Generate with defaults using `helm show values [CHART] [flags]`."
  type        = list(string)
}

# Prometheus

variable "prometheus_install" {
  default     = false
  description = "Whether to deploy the Prometheus Helm chart. See https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack. NOTE: Provided only as a convenience and not supported by or sourced from Oracle - use at your own risk."
  type        = bool
}

variable "prometheus_reapply" {
  default     = false
  description = "Whether to force reapply of the Prometheus Helm chart when no changes are detected, e.g. with state modified externally."
  type        = bool
}

variable "prometheus_namespace" {
  default     = "metrics"
  description = "Kubernetes namespace for deployed resources."
  type        = string
}

variable "prometheus_helm_version" {
  default     = "45.2.0"
  description = "Version of the Helm chart to install. List available releases using `helm search repo [keyword] --versions`."
  type        = string
}

variable "prometheus_helm_values" {
  default     = {}
  description = "Map of individual Helm chart values. See <a href=https://registry.terraform.io/providers/hashicorp/helm/latest/docs/data-sources/template>data.helm_template</a>."
  type        = map(string)
}

variable "prometheus_helm_values_files" {
  default     = []
  description = "Paths to a local YAML files with Helm chart values (as with `helm install -f` which supports multiple). Generate with defaults using `helm show values [CHART] [flags]`."
  type        = list(string)
}

# DCGM exporter

variable "dcgm_exporter_install" {
  default     = false
  description = "Whether to deploy the DCGM exporter Helm chart. See <a href=https://docs.nvidia.com/datacenter/cloud-native/gpu-telemetry/dcgm-exporter.html>DCGM-Exporter</a>. NOTE: Provided only as a convenience and not supported by or sourced from Oracle - use at your own risk."
  type        = bool
}

variable "dcgm_exporter_reapply" {
  default     = false
  description = "Whether to force reapply of the Helm chart when no changes are detected, e.g. with state modified externally."
  type        = bool
}

variable "dcgm_exporter_namespace" {
  default     = "metrics"
  description = "Kubernetes namespace for deployed resources."
  type        = string
}

variable "dcgm_exporter_helm_version" {
  default     = "3.1.5"
  description = "Version of the Helm chart to install. List available releases using `helm search repo [keyword] --versions`."
  type        = string
}

variable "dcgm_exporter_helm_values" {
  default     = {}
  description = "Map of individual Helm chart values. See <a href=https://registry.terraform.io/providers/hashicorp/helm/latest/docs/data-sources/template>data.helm_template</a>."
  type        = map(string)
}

variable "dcgm_exporter_helm_values_files" {
  default     = []
  description = "Paths to a local YAML files with Helm chart values (as with `helm install -f` which supports multiple). Generate with defaults using `helm show values [CHART] [flags]`."
  type        = list(string)
}

# MPI Operator

variable "mpi_operator_install" {
  default     = false
  description = "Whether to deploy the MPI Operator. See <a href=https://github.com/kubeflow/mpi-operator>kubeflow/mpi-operator</a>. NOTE: Provided only as a convenience and not supported by or sourced from Oracle - use at your own risk."
  type        = bool
}

variable "mpi_operator_namespace" {
  default     = "default"
  description = "Kubernetes namespace for deployed resources."
  type        = string
}

variable "mpi_operator_deployment_url" {
  default     = null
  description = "The URL path to the manifest. Leave unset for tags of <a href=https://github.com/kubeflow/mpi-operator>kubeflow/mpi-operator</a> using mpi_operator_version."
  type        = string
}

variable "mpi_operator_version" {
  default     = "0.4.0"
  description = "Version to install. Ignored when an explicit value for mpi_operator_deployment_url is provided."
  type        = string
}

# Whereabouts

variable "whereabouts_install" {
  default     = false
  description = "Whether to deploy the MPI Operator. See <a href=https://github.com/k8snetworkplumbingwg/whereabouts>k8snetworkplumbingwg/whereabouts</a>. NOTE: Provided only as a convenience and not supported by or sourced from Oracle - use at your own risk."
  type        = bool
}

variable "whereabouts_namespace" {
  default     = "default"
  description = "Kubernetes namespace for deployed resources."
  type        = string
}

variable "whereabouts_daemonset_url" {
  default     = null
  description = "The URL path to the manifest. Leave unset for tags of <a href=https://github.com/k8snetworkplumbingwg/whereabouts>k8snetworkplumbingwg/whereabouts</a> using whereabouts_version."
  type        = string
}

variable "whereabouts_version" {
  default     = "master"
  description = "Version to install. Ignored when an explicit value for whereabouts_daemonset_url is provided."
  type        = string
}

# Gatekeeper

variable "gatekeeper_install" {
  default     = false
  description = "Whether to deploy the Gatekeeper Helm chart. See https://github.com/open-policy-agent/gatekeeper. NOTE: Provided only as a convenience and not supported by or sourced from Oracle - use at your own risk."
  type        = bool
}

variable "gatekeeper_namespace" {
  default     = "kube-system"
  description = "Kubernetes namespace for deployed resources."
  type        = string
}

variable "gatekeeper_helm_version" {
  default     = "3.11.0"
  description = "Version of the Helm chart to install. List available releases using `helm search repo [keyword] --versions`."
  type        = string
}

variable "gatekeeper_helm_values" {
  default     = {}
  description = "Map of individual Helm chart values. See <a href=https://registry.terraform.io/providers/hashicorp/helm/latest/docs/data-sources/template>data.helm_template</a>."
  type        = map(string)
}

variable "gatekeeper_helm_values_files" {
  default     = []
  description = "Paths to a local YAML files with Helm chart values (as with `helm install -f` which supports multiple). Generate with defaults using `helm show values [CHART] [flags]`."
  type        = list(string)
}

# Service Account

variable "create_service_account" {
  default     = false
  description = "Wether to create a service account or not."
  type        = bool
}

variable "service_accounts" {
  default = {
    kubeconfigsa = {
      sa_name                 = "kubeconfigsa"
      sa_namespace            = "kube-system"
      sa_cluster_role         = "cluster-admin"
      sa_cluster_role_binding = "kubeconfigsa-crb"
    }
  }
  description = "Map of service accounts and associated parameters."
  type        = map(any)
}

# Argocd

variable "argocd_install" {
  default     = false
  description = "Whether to deploy the Argocd Helm chart. See https://github.com/argoproj/argo-cd. NOTE: Provided only as a convenience and not supported by or sourced from Oracle - use at your own risk."
  type        = bool
}

variable "argocd_namespace" {
  default     = "argocd"
  description = "Kubernetes namespace for deployed resources."
  type        = string
}

variable "argocd_helm_version" {
  default     = "8.1.2"
  description = "Version of the Helm chart to install. List available releases using `helm search repo [keyword] --versions`."
  type        = string
}

variable "argocd_helm_values" {
  default     = {}
  description = "Map of individual Helm chart values. See <a href=https://registry.terraform.io/providers/hashicorp/helm/latest/docs/data-sources/template>data.helm_template</a>."
  type        = map(string)
}

variable "argocd_helm_values_files" {
  default     = []
  description = "Paths to a local YAML files with Helm chart values (as with `helm install -f` which supports multiple). Generate with defaults using `helm show values [CHART] [flags]`."
  type        = list(string)
}

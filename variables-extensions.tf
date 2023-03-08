# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Calico

variable "calico_enabled" {
  default     = false
  description = "Whether to install calico for network pod security policy. NOTE: Provided only as a convenience and not supported by or sourced from Oracle - use at your own risk."
  type        = bool
}

variable "calico_version" {
  default     = "3.24.1"
  description = "The version of Calico to install."
  type        = string
}

variable "calico_mode" {
  default     = "policy-only"
  description = "The type of Calico manifest to install. The default of 'policy-only' is recommended."
  type        = string
  validation {
    condition     = contains(["policy-only", "canal", "vxlan", "ipip", "flannel-migration"], var.calico_mode)
    error_message = "Accepted values are policy-only, canal, vxlan, ipip, or flannel-migration."
  }
}

variable "calico_mtu" {
  default     = 0
  description = "Interface MTU for Calico device(s) (0 = auto)."
  type        = number
}

variable "calico_url" {
  default     = ""
  description = "Optionally override the Calico manifest URL (empty string = auto)."
  type        = string
}

variable "calico_apiserver_enabled" {
  default     = false
  description = "Whether to enable the Calico apiserver."
  type        = bool
}

variable "calico_typha_enabled" {
  default     = false
  description = "Whether to enable Typha (automatically enabled for > 50 nodes)."
  type        = bool
}

variable "calico_typha_replicas" {
  default     = 0
  description = "The number of replicas for the Typha deployment (0 = auto)."
  type        = number
}

variable "calico_staging_dir" {
  default     = "/tmp/calico_install"
  description = "Directory on the operator instance to stage Calico install files."
  type        = string
}

# Metrics server

variable "metrics_server_enabled" {
  default     = false
  description = "Whether to deploy the Kubernetes Metrics Server Helm chart. See https://github.com/kubernetes-sigs/metrics-server. NOTE: Provided only as a convenience and not supported by or sourced from Oracle - use at your own risk."
  type        = bool
}

variable "metrics_server_namespace" {
  default     = "kube-system"
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
  description = "Map of individual Helm chart values. See https://registry.terraform.io/providers/hashicorp/helm/latest/docs/data-sources/template."
  type        = map(string)
}

variable "metrics_server_helm_values_files" {
  default     = []
  description = "Paths to a local YAML files with Helm chart values (as with `helm install -f` which supports multiple). Generate with defaults using `helm show values [CHART] [flags]`."
  type        = list(string)
}

# Cluster autoscaler

variable "cluster_autoscaler_enabled" {
  default     = false
  description = "Whether to deploy the Kubernetes Cluster Autoscaler Helm chart. See https://github.com/kubernetes/autoscaler. NOTE: Provided only as a convenience and not supported by or sourced from Oracle - use at your own risk."
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
  description = "Map of individual Helm chart values. See https://registry.terraform.io/providers/hashicorp/helm/latest/docs/data-sources/template."
  type        = map(string)
}

variable "cluster_autoscaler_helm_values_files" {
  default     = []
  description = "Paths to a local YAML files with Helm chart values (as with `helm install -f` which supports multiple). Generate with defaults using `helm show values [CHART] [flags]`."
  type        = list(string)
}

# Prometheus

variable "prometheus_enabled" {
  default     = false
  description = "Whether to deploy the Prometheus Helm chart. See https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack. NOTE: Provided only as a convenience and not supported by or sourced from Oracle - use at your own risk."
  type        = bool
}

variable "prometheus_namespace" {
  default     = "kube-system"
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
  description = "Map of individual Helm chart values. See https://registry.terraform.io/providers/hashicorp/helm/latest/docs/data-sources/template."
  type        = map(string)
}

variable "prometheus_helm_values_files" {
  default     = []
  description = "Paths to a local YAML files with Helm chart values (as with `helm install -f` which supports multiple). Generate with defaults using `helm show values [CHART] [flags]`."
  type        = list(string)
}

# Gatekeeper

variable "gatekeeper_enabled" {
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
  description = "Map of individual Helm chart values. See https://registry.terraform.io/providers/hashicorp/helm/latest/docs/data-sources/template."
  type        = map(string)
}

variable "gatekeeper_helm_values_files" {
  default     = []
  description = "Paths to a local YAML files with Helm chart values (as with `helm install -f` which supports multiple). Generate with defaults using `helm show values [CHART] [flags]`."
  type        = list(string)
}

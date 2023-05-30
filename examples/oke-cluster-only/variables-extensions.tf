# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# CNI: Calico

variable "calico_install" { default = false }
variable "calico_reapply" { default = false }
variable "calico_version" { default = "3.24.1" }
variable "calico_mode" { default = "policy-only" }
variable "calico_mtu" { default = 0 }
variable "calico_url" { default = "" }
variable "calico_apiserver_install" { default = false }
variable "calico_typha_install" { default = false }
variable "calico_typha_replicas" { default = 0 }
variable "calico_staging_dir" { default = "/tmp/calico_install" }
variable "calico_namespace" { default = "network" }
variable "calico_helm_version" { default = "3.25.0" }
# variable "calico_helm_values" {
#   default = {}
#   type    = map(string)
# }
# variable "calico_helm_values_files" {
#   default = []
#   type    = list(string)
# }

# CNI: Multus

variable "multus_install" { default = false }
variable "multus_namespace" { default = "network" }
variable "multus_daemonset_url" {
  default = null
  type    = string
}
variable "multus_version" { default = "3.9.3" }

# Metrics server

variable "metrics_server_install" { default = false }
variable "metrics_server_namespace" { default = "metrics" }
variable "metrics_server_helm_version" { default = "3.8.3" }
# variable "metrics_server_helm_values" {
#   default = {}
#   type    = map(string)
# }
# variable "metrics_server_helm_values_files" {
#   default = []
#   type    = list(string)
# }

# Cluster autoscaler

variable "cluster_autoscaler_install" { default = false }
variable "cluster_autoscaler_namespace" { default = "kube-system" }
variable "cluster_autoscaler_helm_version" { default = "9.24.0" }
# variable "cluster_autoscaler_helm_values" {
#   default = {}
#   type    = map(string)
# }
# variable "cluster_autoscaler_helm_values_files" {
#   default = []
#   type    = list(string)
# }

# Prometheus

variable "prometheus_install" { default = false }
variable "prometheus_reapply" { default = false }
variable "prometheus_namespace" { default = "metrics" }
variable "prometheus_helm_version" { default = "45.2.0" }
# variable "prometheus_helm_values" {
#   default = {}
#   type    = map(string)
# }
# variable "prometheus_helm_values_files" {
#   default = []
#   type    = list(string)
# }

# Gatekeeper

variable "gatekeeper_install" { default = false }
variable "gatekeeper_namespace" { default = "kube-system" }
variable "gatekeeper_helm_version" { default = "3.11.0" }
# variable "gatekeeper_helm_values" {
#   default = {}
#   type    = map(string)
# }
# variable "gatekeeper_helm_values_files" {
#   default = []
#   type    = list(string)
# }

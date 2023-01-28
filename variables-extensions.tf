# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

variable "check_node_active" {
  default     = "none"
  description = "check worker node is active"
  type        = string

  validation {
    condition     = contains(["none", "one", "all"], var.check_node_active)
    error_message = "Accepted values are none, one or all."
  }
}

variable "upgrade_nodepool" { # TODO Update
  default     = false
  description = "Whether to upgrade the Kubernetes version of the node pools."
  type        = bool
}

variable "node_pools_to_drain" { # TODO Update
  default     = ["none"]
  description = "List of node pool names to drain during an upgrade. This list is used to determine the worker nodes to drain."
  type        = list(string)
}

# Oracle Container Image Registry (OCIR)
variable "email_address" {
  default     = "none"
  description = "The email address used for OCIR."
  type        = string
}

variable "secret_id" {
  default     = "none"
  description = "The OCID of the Secret on OCI Vault which holds the authentication token."
  type        = string
}

variable "secret_name" {
  default     = "ocirsecret"
  description = "The name of the Kubernetes secret that will hold the authentication token"
  type        = string
}

variable "secret_namespace" {
  default     = "default"
  description = "The Kubernetes namespace for where the OCIR secret will be created."
  type        = string
}

variable "username" {
  default     = "none"
  description = "The username that can login to the selected tenancy. This is different from tenancy_id. *Required* if secret_id is set."
  type        = string
}

# Calico
variable "enable_calico" {
  default     = false
  description = "Whether to install calico for network pod security policy"
  type        = bool
}

variable "calico_version" {
  default     = "3.24.1"
  description = "The version of Calico to install"
  type        = string
}

variable "calico_mode" {
  default     = "policy-only"
  description = "The type of Calico manifest to install"
  type        = string
  validation {
    condition     = contains(["policy-only", "canal", "vxlan", "ipip", "flannel-migration"], var.calico_mode)
    error_message = "Accepted values are policy-only, canal, vxlan, ipip, or flannel-migration."
  }
}

variable "calico_mtu" {
  default     = 0
  description = "Interface MTU for Calico device(s) (0 = auto)"
  type        = number
}

variable "calico_url" {
  default     = ""
  description = "Optionally override the Calico manifest URL (empty string = auto)"
  type        = string
}

variable "calico_apiserver_enabled" {
  default     = false
  description = "Whether to enable the Calico apiserver"
  type        = bool
}

variable "typha_enabled" {
  default     = false
  description = "Whether to enable Typha (automatically enabled for > 50 nodes)"
  type        = bool
}

variable "typha_replicas" {
  default     = 0
  description = "The number of replicas for the Typha deployment (0 = auto)"
  type        = number
}

variable "calico_staging_dir" {
  default     = "/tmp/calico_install"
  description = "Directory on the operator instance to stage Calico install files"
  type        = string
}

# Horizontal and vertical pod autoscaling
variable "enable_metric_server" {
  description = "Whether to install metricserver for collecting metrics and for HPA"
  default     = false
  type        = bool
}

variable "enable_vpa" {
  default     = false
  description = "Whether to install vertical pod autoscaler"
  type        = bool
}

variable "vpa_version" {
  default     = "0.8"
  description = "The version of vertical pod autoscaler to install"
  type        = string
}

# Gatekeeper
variable "enable_gatekeeper" {
  default     = false
  description = "Whether to install Gatekeeper"
  type        = bool
}

variable "gatekeeper_version" {
  default     = "3.7"
  description = "The version of Gatekeeper to install"
  type        = string
}

# Service account
variable "create_service_account" {
  default     = false
  description = "Whether to create a service account. A service account is required for CI/CD. see https://docs.cloud.oracle.com/iaas/Content/ContEng/Tasks/contengaddingserviceaccttoken.htm"
  type        = bool
}

variable "service_account_name" {
  default     = "kubeconfigsa"
  description = "The name of service account to create"
  type        = string
}

variable "service_account_namespace" {
  default     = "kube-system"
  description = "The Kubernetes namespace where to create the service account"
  type        = string
}

variable "service_account_cluster_role_binding" {
  default     = "cluster-admin"
  description = "The cluster role binding name"
  type        = string
}

# Cluster autoscaler
variable "deploy_cluster_autoscaler" {
  default     = false
  description = "Whether to deploy the cluster autoscaler."
  type        = bool
}

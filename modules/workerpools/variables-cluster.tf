# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

variable "apiserver_private_host" {
  default     = ""
  description = "Cluster private apiserver IP address. Resolved automatically when OKE cluster is found using cluster_id."
  type        = string
}

variable "apiserver_public_host" {
  default     = ""
  description = "Cluster public apiserver IP address, when enabled. Resolved automatically when OKE cluster is found using cluster_id."
  type        = string
}

variable "cluster_dns" {
  default     = "10.96.5.5"
  description = "Cluster DNS resolver IP address. The provided value used with default `servicesCidr` 10.96.0.0/16 should only require modification in the case of conflict."
  type        = string
}

variable "cni_type" {
  default     = "flannel"
  description = "The CNI for the cluster. Choose between flannel or npn"
  type        = string
  validation {
    condition     = contains(["flannel", "npn"], var.cni_type)
    error_message = "Accepted values are flannel or npn"
  }
}

variable "label_prefix" {
  default     = ""
  description = "A string that will be prepended to all resources"
  type        = string
}

variable "kubernetes_version" {
  default     = "v1.24.1"
  description = "The Kubernetes version"
  type        = string
}

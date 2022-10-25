# Copyright (c) 2022 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

variable "apiserver_host" {
  default     = ""
  description = "Cluster apiserver IP address only e.g. 10.0.0.1. Resolved automatically when OKE cluster is found using cluster_id."
  type        = string
}

variable "cluster_dns" {
  default     = "10.96.5.5"
  description = "Cluster DNS resolver IP address"
  type        = string
}

variable "cluster_id" {
  default     = ""
  description = "An existing OKE cluster ID for worker nodes to join. Resolved automatically when OKE control plane is managed within same Terraform state."
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

variable "cluster_ca_cert" {
  default     = ""
  description = "Cluster CA certificate. Required for unmanaged instance pools for secure control plane connection."
  type        = string
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
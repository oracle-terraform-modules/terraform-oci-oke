# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# General

variable "output_detail" { default = false }
variable "timezone" { default = "Etc/UTC" }

# Cluster

variable "cluster_type" {
  description = "The cluster type. See <a href=https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengworkingwithenhancedclusters.htm>Working with Enhanced Clusters and Basic Clusters</a> for more information. NOTE: An Enhanced cluster is required for self-managed worker pools (mode != Node Pool)."
  type        = string
}
variable "cluster_name" {
  default = null
  type    = string
}
variable "cni_type" { type = string }
variable "pods_cidr" {
  default = "10.244.0.0/16"
  type    = string
}
variable "services_cidr" {
  default = "10.96.0.0/16"
  type    = string
}
variable "kubernetes_version" { default = "v1.32.1" }

variable "cluster_kms_vault_id" {
  default = null
  type    = string
}
variable "cluster_kms_key_id" {
  default = ""
  type    = string
}

variable "use_signed_images" {
  default = false
  type    = bool
}
variable "image_signing_keys" {
  default = []
  type    = set(string)
}

variable "load_balancers" {
  default = "Public"
  type    = string
}
variable "preferred_load_balancer" {
  default = "Public"
  type    = string
}

variable "cluster_tags" {
  default = {}
  type    = map(any)
}

# Oracle Container Image Registry (OCIR)

variable "ocir_email_address" {
  default = null
  type    = string
}
variable "ocir_secret_name" { default = "ocirsecret" }
variable "ocir_secret_namespace" { default = "default" }
variable "ocir_username" {
  default = null
  type    = string
}
variable "ocir_kms_vault_id" {
  default = null
  type    = string
}
variable "ocir_kms_secret_id" {
  default = null
  type    = string
}

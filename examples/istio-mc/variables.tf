# Copyright (c) 2024 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# OCI Provider parameters
variable "api_fingerprint" {
  default     = ""
  description = "Fingerprint of the API private key to use with OCI API."
  type        = string
}

variable "api_private_key_path" {
  default     = ""
  description = "The path to the OCI API private key."
  type        = string
}

variable "home_region" {
  description = "The tenancy's home region. Use the short form in lower case e.g. phoenix."
  type        = string
}

variable "tenancy_id" {
  description = "The tenancy id of the OCI Cloud Account in which to create the resources."
  type        = string
}

variable "user_id" {
  description = "The id of the user that Terraform will use to create the resources."
  type        = string
  default     = ""
}

# General OCI parameters
variable "compartment_id" {
  description = "The compartment id where to create all resources."
  type        = string
}

# ssh keys
variable "ssh_private_key_path" {
  default     = "none"
  description = "The path to ssh private key."
  type        = string
}

variable "ssh_public_key_path" {
  default     = "none"
  description = "The path to ssh public key."
  type        = string
}

# clusters

variable "clusters" {
  description = "A map of cidrs for vcns, pods and services for each region"
  type        = map(any)
  default = {
    c1 = { region = "sydney", vcn = "10.1.0.0/16", pods = "10.201.0.0/16", services = "10.101.0.0/16", enabled = true }
    c2 = { region = "melbourne", vcn = "10.2.0.0/16", pods = "10.202.0.0/16", services = "10.102.0.0/16", enabled = true }
  }
}

variable "kubernetes_version" {
  default     = "v1.32.1"
  description = "The version of Kubernetes to use."
  type        = string
}

variable "cluster_type" {
  default     = "basic"
  description = "Whether to use basic or enhanced OKE clusters"
  type        = string

  validation {
    condition     = contains(["basic", "enhanced"], lower(var.cluster_type))
    error_message = "Accepted values are 'basic' or 'enhanced'."
  }
}

variable "oke_control_plane" {
  default     = "public"
  description = "Whether to keep all OKE control planes public or private."
  type        = string

  validation {
    condition     = contains(["public", "private"], lower(var.oke_control_plane))
    error_message = "Accepted values are 'public' or 'private'."
  }
}

variable "preferred_cni" {
  default     = "flannel"
  description = "Whether to use flannel or NPN"
  type        = string

  validation {
    condition     = contains(["flannel", "npn"], lower(var.preferred_cni))
    error_message = "Accepted values are 'flannel' or 'npn'."
  }
}

# node pools
variable "timezone" {
  type        = string
  description = "Preferred timezone of computes"
  default     = "Australia/Sydney"
}

variable "nodepools" {
  type        = any
  description = "Node pools for all clusters"
  default = {
    np1 = {
      shape            = "VM.Standard.E4.Flex",
      ocpus            = 2,
      memory           = 32,
      size             = 3,
      boot_volume_size = 150,
    }
  }
}

# istio
variable "istio_version" {
  default     = "1.20.2"
  description = "Istio version to install"
  type        = string
}

variable "istio_mesh_id" {
  description = "mesh id to be used"
  type        = string
  default     = "yggdrasil"
}

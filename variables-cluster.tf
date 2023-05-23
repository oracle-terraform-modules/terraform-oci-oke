# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

variable "create_cluster" {
  default     = true
  description = "Whether to create the OKE cluster and dependent resources."
  type        = bool
}

variable "cluster_name" {
  default     = null
  description = "The name of oke cluster."
  type        = string
}

variable "cluster_type" {
  default     = "basic"
  description = "The cluster type. See <a href=https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengworkingwithenhancedclusters.htm>Working with Enhanced Clusters and Basic Clusters</a> for more information."
  type        = string
  validation {
    condition     = contains(["basic", "enhanced"], lower(var.cluster_type))
    error_message = "Accepted values are 'basic' or 'enhanced'."
  }
}

variable "control_plane_is_public" {
  default     = false
  description = "Whether the Kubernetes control plane endpoint should be allocated a public IP address."
  type        = bool
}

variable "control_plane_nsg_ids" {
  default     = []
  description = "An additional list of network security groups (NSG) ids for the cluster endpoint."
  type        = set(string)
}

variable "cni_type" {
  default     = "flannel"
  description = "The CNI for the cluster: 'flannel' or 'npn'. See https://docs.oracle.com/en-us/iaas/Content/ContEng/Concepts/contengpodnetworking.htm."
  type        = string
  validation {
    condition     = contains(["flannel", "npn"], var.cni_type)
    error_message = "Accepted values are flannel or npn"
  }
}

variable "pods_cidr" {
  default     = "10.244.0.0/16"
  description = "The CIDR range used for IP addresses by the pods. A /16 CIDR is generally sufficient. This CIDR should not overlap with any subnet range in the VCN (it can also be outside the VCN CIDR range). Ignored when cni_type = 'npn'."
  type        = string
}

variable "services_cidr" {
  default     = "10.96.0.0/16"
  description = "The CIDR range used within the cluster by Kubernetes services (ClusterIPs). This CIDR should not overlap with the VCN CIDR range."
  type        = string
}

variable "kubernetes_version" {
  default     = "v1.25.4"
  description = "The version of kubernetes to use when provisioning OKE or to upgrade an existing OKE cluster to."
  type        = string
}

variable "cluster_kms_key_id" {
  default     = ""
  description = "The id of the OCI KMS key to be used as the master encryption key for Kubernetes secrets encryption."
  type        = string
}

variable "use_signed_images" {
  default     = false
  description = "Whether to enforce the use of signed images. If set to true, at least 1 RSA key must be provided through image_signing_keys."
  type        = bool
}

variable "image_signing_keys" {
  default     = []
  description = "A list of KMS key ids used by the worker nodes to verify signed images. The keys must use RSA algorithm."
  type        = set(string)
}

variable "load_balancers" {
  default     = "public"
  description = "The type of subnets to create for load balancers."
  type        = string
  validation {
    condition     = contains(["public", "internal", "both"], var.load_balancers)
    error_message = "Accepted values are public, internal or both."
  }
}

variable "preferred_load_balancer" {
  # values: public, internal.
  # When creating an internal load balancer, the internal annotation must still be specified regardless
  default     = "public"
  description = "The preferred load balancer subnets that OKE will automatically choose when creating a load balancer. valid values are public or internal. if 'public' is chosen, the value for load_balancers must be either 'public' or 'both'. If 'private' is chosen, the value for load_balancers must be either 'internal' or 'both'."
  type        = string
  validation {
    condition     = contains(["public", "internal"], var.preferred_load_balancer)
    error_message = "Accepted values are public or internal."
  }
}

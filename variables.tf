# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

# Identity and access parameters
variable "api_fingerprint" {
  description = "fingerprint of oci api private key"
  default     = ""
}

variable "api_private_key_path" {
  description = "path to oci api private key"
  default     = ""
}

variable "compartment_name" {
  type        = "string"
  description = "compartment name"
}

variable "compartment_ocid" {
  type        = "string"
  description = "compartment ocid"
}

variable "tenancy_ocid" {
  type        = "string"
  description = "tenancy id"
  default     = ""
}

variable "user_ocid" {
  type        = "string"
  description = "user ocid"
  default     = ""
}

# ssh keys
variable "ssh_private_key_path" {
  description = "path to ssh private key"
}

variable "ssh_public_key_path" {
  description = "path to ssh public key"
}

# general oci parameters
variable "disable_auto_retries" {
  default = true
}

variable "label_prefix" {
  type    = "string"
  default = ""
}

variable "region" {
  # List of regions: https://docs.cloud.oracle.com/iaas/Content/General/Concepts/regions.htm#ServiceAvailabilityAcrossRegions
  description = "region"
  default     = ""
}

# networking parameters
variable "newbits" {
  type        = "map"
  description = "new mask for the subnet within the virtual network. use as newbits parameter for cidrsubnet function"

  default = {
    bastion   = "8"
    "lb"      = "8"
    "workers" = "8"
  }
}

variable "vcn_cidr" {
  type        = "string"
  description = "cidr block of VCN"
  default     = "10.0.0.0/16"
}

variable "vcn_dns_name" {
  type    = "string"
  default = "baseoci"
}

variable "vcn_name" {
  type        = "string"
  description = "name of vcn"
  default     = "oke vcn"
}

# nat
variable "create_nat_gateway" {
  description = "whether to create a nat gateway"
  default     = false
}

variable "nat_gateway_name" {
  description = "display name of the nat gateway"
  default     = "nat"
}

# service gateway
variable "create_service_gateway" {
  description = "whether to create a service gateway"
  default     = false
}

variable "service_gateway_name" {
  description = "name of service gateway"
  default     = "object_storage_gateway"
}

variable "subnets" {
  description = "zero-based index of the subnet when the network is masked with the newbit."
  type        = "map"

  default = {
    bastion     = 11
    lb_ad1      = 12
    lb_ad2      = 22
    lb_ad3      = 32
    workers_ad1 = 13
    workers_ad2 = 23
    workers_ad3 = 33
  }
}

# bastion
variable "bastion_shape" {
  description = "shape of bastion instance"
  default     = "VM.Standard2.1"
}

variable "create_bastion" {
  default = true
}

variable "enable_instance_principal" {
  description = "enable the bastion hosts to call OCI API services without requiring api key"
  default     = false
}

variable "image_ocid" {
  default = "NONE"
}

variable "image_operating_system" {
  # values = Oracle Linux, CentOS, Canonical Ubuntu
  default     = "Oracle Linux"
  description = "operating system to use for the bastion"
}

variable "image_operating_system_version" {
  # Versions of available operating systems can be found here: https://docs.cloud.oracle.com/iaas/images/
  default     = "7.6"
  description = "version of selected operating system"
}

# availability domains
variable "availability_domains" {
  description = "ADs where to provision resources"
  type        = "map"

  # set to 0 to disable
  default = {
    bastion     = 1
    lb_ad1      = 1
    lb_ad2      = 2
    lb_ad3      = 3
    workers_ad1 = 1
    workers_ad2 = 2
    workers_ad3 = 3
  }
}

# oke
variable "cluster_name" {
  description = "name of oke cluster"
  default     = "okecluster"
}

variable "dashboard_enabled" {
  description = "whether to enable kubernetes dashboard"
  default     = true
}

variable "kubernetes_version" {
  description = "version of kubernetes to use"
  default     = "LATEST"
}

variable "node_pools" {
  description = "number of node pools"
  default     = 1
}

variable "node_pool_name_prefix" {
  description = "prefix of node pool name"
  default     = "np"
}

variable "node_pool_node_image_name" {
  description = "name of image to use"
  default     = "Oracle-Linux-7.5"
}

variable "node_pool_node_shape" {
  description = "shape of worker nodes"
  default     = "VM.Standard2.1"
}

variable "node_pool_quantity_per_subnet" {
  description = "number of workers in node pool"
  default     = 1
}

variable "nodepool_topology" {
  description = "whether to use 2 ADs or 3ADs for the node pool. Possible values are 2 or 3 only"
  default     = 3
}

variable "pods_cidr" {
  description = "This is the CIDR range used for IP addresses by your pods. A /16 CIDR is generally sufficient. This CIDR should not overlap with any subnet range in the VCN (it can also be outside the VCN CIDR range)."
  default     = "10.244.0.0/16"
}

variable "services_cidr" {
  description = "This is the CIDR range used by exposed Kubernetes services (ClusterIPs). This CIDR should not overlap with the VCN CIDR range."
  default     = "10.96.0.0/16"
}

variable "tiller_enabled" {
  description = "whether to enable tiller"
  default     = true
}

variable "worker_mode" {
  description = "whether to provision public or private workers"
  default     = "private"
}

# ocir

variable "create_auth_token" {
  description = "whether to create an auth token to use with OCIR"
  default     = false
}

variable "email_address" {
  description = "email address used for OICR"
  default     = ""
}

variable "ocir_urls" {
  # Region and region codes: https://docs.cloud.oracle.com/iaas/Content/General/Concepts/regions.htm#ServiceAvailabilityAcrossRegions
  description = "urls of ocir"
  type        = "map"

  default = {
    ap-tokyo-1     = "nrt.ocir.io"
    us-phoenix-1   = "phx.ocir.io"
    us-ashburn-1   = "iad.ocir.io"
    eu-frankfurt-1 = "fra.ocir.io"
    uk-london-1    = "lhr.ocir.io"
    ca-toronto-1   = "yyz.ocir.io"
  }
}

variable "tenancy_name" {
  description = "tenancy name"
  default     = ""
}

variable "username" {
  description = "username to access OCIR"
  default     = ""
}

# helm
variable "helm_version" {
  description = "version of helm to install"
  default     = "2.13.0"
}

variable "install_helm" {
  description = "whether to install helm client on the bastion"
  default     = false
}

# calico
variable "calico_version" {
  description = "version of calico to install"
  default     = "3.6"
}

variable "install_calico" {
  description = "whether to install calico for network pod security policy"
  default     = false
}

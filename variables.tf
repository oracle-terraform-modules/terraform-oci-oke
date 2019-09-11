# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

# Identity and access parameters
variable "api_fingerprint" {
  description = "fingerprint of oci api private key"
}

variable "api_private_key_path" {
  description = "path to oci api private key"
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
}

variable "user_ocid" {
  type        = "string"
  description = "user ocid"
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
  default = "oke"
}

variable "region" {
  # List of regions: https://docs.cloud.oracle.com/iaas/Content/General/Concepts/regions.htm#ServiceAvailabilityAcrossRegions
  description = "region"
  default     = "us-phoenix-1"
}

# networking parameters
variable "newbits" {
  type        = "map"
  description = "new mask for the subnet within the virtual network. use as newbits parameter for cidrsubnet function"

  default = {
    bastion = 13
    lb      = 11
    workers = 2
  }
}

variable "vcn_cidr" {
  type        = "string"
  description = "cidr block of VCN"
  default     = "10.0.0.0/16"
}

variable "vcn_dns_name" {
  type    = "string"
  default = "oke"
}

variable "vcn_name" {
  type        = "string"
  description = "name of vcn"
  default     = "oke vcn"
}

# nat
variable "create_nat_gateway" {
  description = "whether to create a nat gateway"
  default     = true
}

variable "nat_gateway_name" {
  description = "display name of the nat gateway"
  default     = "nat"
}

# service gateway
variable "create_service_gateway" {
  description = "whether to create a service gateway"
  default     = true
}

variable "service_gateway_name" {
  description = "name of service gateway"
  default     = "sg"
}

variable "subnets" {
  description = "zero-based index of the subnet when the network is masked with the newbit."
  type        = "map"

  default = {
    bastion     = 32
    int_lb_ad1  = 16
    int_lb_ad2  = 17
    int_lb_ad3  = 18
    pub_lb_ad1  = 19
    pub_lb_ad2  = 20
    pub_lb_ad3  = 21
    workers_ad1 = 1
    workers_ad2 = 2
    workers_ad3 = 3
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

variable "bastion_access" {
  description = "cidr from where the bastion can be sshed into. Default is ANYWHERE and equivalent to 0.0.0.0/0"
  default     = "ANYWHERE"
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
  description = "ADs where to provision non-OKE resources"
  type        = "map"

  default = {
    bastion = 1
  }
}

# bastion packages
variable "bastion_package_update" {
  description = "Update apt database on first boot if bastion host uses Ubuntu as Linux distribution"
  type        = bool
  default     = true
}
variable "bastion_package_upgrade" {
  description = "Upgrade the instance on first boot"
  type        = bool
  default     = true
}

# oke

variable "allow_node_port_access" {
  description = "whether to allow access to NodePorts when worker nodes are deployed in public mode"
  default     = false
}

variable "allow_worker_ssh_access" {
  description = "whether to allow ssh access to worker nodes when worker nodes are deployed in public mode"
  default     = false
}

variable "cluster_name" {
  description = "name of oke cluster"
  default     = "oke"
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
  type        = map(any)
  description = "number of node pools"
}

variable "node_pool_name_prefix" {
  description = "prefix of node pool name"
  default     = "np"
}

variable "node_pool_image_id" {
  description = "OCID of custom image to use for worker node"
  default     = "NONE"
}

variable "node_pool_os" {
  description = "name of image to use"
  default     = "Oracle Linux"
}

variable "node_pool_os_version" {
  description = "version of image Operating System to use"
  default     = "7.6"
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

# oke load balancers

variable "lb_subnet_type" {
  description = "type of load balancer subnets to create."
  # values: both, internal, public
  default = "public"
}

variable "preferred_lb_ads" {
  description = "preferred Availability Domains for Load Balancers"
  type        = list
  # list elements: choose 2 from ad1, ad2, ad3 (regarless of the number of domains your region has)
  default = ["ad1", "ad2"]
}

variable "preferred_lb_subnets" {
  description = "preferred load balancer subnets that OKE will automatically choose when creating a load balancer. Valid values are public or internal. If 'public' is chosen, the value for lb_subnet_type must be either 'public' or 'both'. If 'private' is chosen, the value for lb_subnet_type must be either 'internal' or 'both'"
  # values: public, internal. 
  # When creating an internal load balancer, the internal annotation must still be specified regardless 
  default = "public"
}

# ocir

variable "create_auth_token" {
  description = "whether to create an auth token to use with OCIR"
  default     = false
}

variable "email_address" {
  description = "email address used for OCIR"
  default     = ""
}

variable "ocir_urls" {
  # Region and region codes: https://docs.cloud.oracle.com/iaas/Content/General/Concepts/regions.htm#ServiceAvailabilityAcrossRegions
  description = "urls of ocir"
  type        = "map"

  default = {
    ap-sydney-1    = "syd.ocir.io"
    ap-mumbai-1    = "bom.ocir.io"
    ap-seoul-1     = "icn.ocir.io"
    ap-tokyo-1     = "nrt.ocir.io"
    ca-toronto-1   = "yyz.ocir.io"
    eu-frankfurt-1 = "fra.ocir.io"
    eu-zurich-1    = "zrh.ocir.io"
    sa-saopaulo-1  = "gru.ocir.io"
    uk-london-1    = "lhr.ocir.io"
    us-ashburn-1   = "iad.ocir.io"
    us-phoenix-1   = "phx.ocir.io"
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
variable "add_incubator_repo" {
  description = "whether to add incubator repo"
  default     = false
}

variable "add_jetstack_repo" {
  description = "whether to add jetstack repo. Required for cert-manager"
  default     = false
}

variable "helm_version" {
  description = "version of helm to install"
  default     = "2.14.3"
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

variable "install_metricserver" {
  description = "whether to install metricserver for collecting metrics and for HPA"
  default     = false
}

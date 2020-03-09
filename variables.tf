# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Identity and access parameters
variable "api_fingerprint" {
  description = "fingerprint of oci api private key"
  type        = string
}

variable "api_private_key_path" {
  description = "path to oci api private key"
  type        = string
}

variable "compartment_id" {
  description = "compartment id where to create all resources"
  type        = string
}

variable "tenancy_id" {
  description = "tenancy id where to create the sources"
  type        = string
}

variable "user_id" {
  description = "id of user that terraform will use to create the resources"
  type        = string
}

# ssh keys
variable "ssh_private_key_path" {
  description = "path to ssh private key"
  type        = string
}

variable "ssh_public_key_path" {
  description = "path to ssh public key"
  type        = string
}

# general oci parameters
variable "disable_auto_retries" {
  description = ""
  default     = true
  type        = bool
}

variable "label_prefix" {
  description = "a string that will be prepended to all resources"
  type        = string
}

variable "region" {
  # List of regions: https://docs.cloud.oracle.com/iaas/Content/General/Concepts/regions.htm#ServiceAvailabilityAcrossRegions
  description = "the oci region where resources will be created"
  type        = string
}

# networking parameters

variable "nat_gateway_enabled" {
  description = "whether to create a nat gateway in the vcn."
  default     = true
  type        = bool
}

variable "netnum" {
  description = "zero-based index of the subnet when the network is masked with the newbit. use as netnum parameter for cidrsubnet function"
  default = {
    admin   = 33
    bastion = 32
    int_lb  = 16
    pub_lb  = 17
    workers = 1
  }
  type = map
}

variable "newbits" {
  description = "new mask for the subnet within the virtual network. use as newbits parameter for cidrsubnet function"
  default = {
    admin   = 13
    bastion = 13
    lb      = 11
    workers = 2
  }
  type = map
}

variable "vcn_cidr" {
  description = "cidr block of VCN"
  default     = "10.0.0.0/16"
  type        = string
}

variable "vcn_dns_label" {
  type = string
}

variable "vcn_name" {
  description = "name of vcn"
  type        = string
}

# bastion
variable "bastion_access" {
  description = "cidr from where the bastion can be sshed into. default is ANYWHERE and equivalent to 0.0.0.0/0"
  default     = "ANYWHERE"
  type        = string
}

variable "bastion_enabled" {
  description = "whether to create a bastion host"
  default     = true
  type        = bool
}

variable "bastion_image_id" {
  description = "image id to use for bastion."
  default     = "Autonomous"
  type        = string
}

variable "bastion_notification_enabled" {
  description = "whether to enable notification on the bastion host"
  default     = false
  type        = bool
}

variable "bastion_notification_endpoint" {
  description = "the subscription notification endpoint for the bastion. email address to be notified."
  type        = string
}

variable "bastion_notification_protocol" {
  description = "The notification protocol used."
  default     = "EMAIL"
  type        = string
}

variable "bastion_notification_topic" {
  description = "the name of the notification topic."
  default     = "bastion"
  type        = string
}

variable "bastion_package_upgrade" {
  description = "whether to upgrade the bastion host packages after provisioning. it’s useful to set this to false during development so the bastion is provisioned faster."
  default     = true
  type        = bool
}

variable "bastion_shape" {
  description = "shape of bastion instance"
  type        = string
}

variable "bastion_timezone" {
  description = "the preferred timezone for the bastion host."
  type        = string
}

# admin server

variable "admin_enabled" {
  description = "whether to create an admin server in a private subnet"
  default     = true
  type        = bool
}

variable "admin_image_id" {
  description = "image id to use for admin server. set either an image id or to Oracle. if value is set to Oracle, the default Oracle Linux platform image will be used."
  default     = "Oracle"
  type        = string
}

variable "admin_instance_principal" {
  description = "enable the admin server host to call OCI API services without requiring api key"
  default     = true
  type        = bool
}

variable "admin_notification_enabled" {
  description = "whether to enable notification on the admin host"
  default     = false
  type        = bool
}

variable "admin_notification_endpoint" {
  description = "the subscription notification endpoint for the admin. email address to be notified."
  type        = string
}

variable "admin_notification_protocol" {
  description = "the notification protocol used."
  default     = "EMAIL"
  type        = string
}

variable "admin_notification_topic" {
  description = "the name of the notification topic."
  default     = "admin"
  type        = string
}

variable "admin_package_upgrade" {
  description = "whether to upgrade the bastion host packages after provisioning. it’s useful to set this to false during development so the bastion is provisioned faster."
  default     = true
  type        = bool
}

variable "admin_shape" {
  description = "shape of admin server instance"
  default     = ""
  type        = string
}

variable "admin_timezone" {
  description = "the preferred timezone for the admin host."
  type        = string
}

# availability domains
variable "availability_domains" {
  description = "Availability Domains where to provision non-OKE resources"
  default = {
    bastion = 1
    admin   = 1
  }
  type = map
}

# oke

variable "allow_node_port_access" {
  description = "whether to allow access to NodePorts when worker nodes are deployed in public mode"
  default     = false
  type        = bool
}

variable "allow_worker_ssh_access" {
  description = "whether to allow ssh access to worker nodes when worker nodes are deployed in public mode"
  default     = false
  type        = bool
}

variable "cluster_name" {
  description = "name of oke cluster"
  type        = string
}

variable "dashboard_enabled" {
  description = "whether to enable kubernetes dashboard."
  default     = false
  type        = bool
}

variable "kubernetes_version" {
  description = "version of kubernetes to use"
  default     = "LATEST"
  type        = string
}

variable "node_pools" {
  description = "tuple node pools. each key maps to a node pool. each value is a tuple of shape (string) and size(number)"
  type        = map(any)
}

variable "node_pool_name_prefix" {
  description = "prefix of node pool name"
  default     = "np"
  type        = string
}

variable "node_pool_image_id" {
  description = "ocid of custom image to use for worker node"
  default     = "NONE"
  type        = string
}

variable "node_pool_os" {
  description = "name of image to use"
  default     = "Oracle Linux"
  type        = string
}

variable "node_pool_os_version" {
  description = "version of image Operating System to use"
  default     = "7.7"
  type        = string
}

variable "pods_cidr" {
  description = "this is the CIDR range used for IP addresses by the pods. a /16 CIDR is generally sufficient. This CIDR should not overlap with any subnet range in the VCN (it can also be outside the VCN CIDR range)."
  default     = "10.244.0.0/16"
  type        = string
}

variable "services_cidr" {
  description = "This is the CIDR range used by exposed Kubernetes services (ClusterIPs). this CIDR should not overlap with the VCN CIDR range."
  default     = "10.96.0.0/16"
  type        = string
}

variable "worker_mode" {
  description = "whether to provision public or private workers"
  default     = "private"
  type        = string
}

# oke load balancers

variable "lb_subnet_type" {
  description = "type of load balancer subnets to create."
  # values: both, internal, public
  default = "public"
  type    = string
}

variable "preferred_lb_subnets" {
  description = "preferred load balancer subnets that OKE will automatically choose when creating a load balancer. valid values are public or internal. if 'public' is chosen, the value for lb_subnet_type must be either 'public' or 'both'. If 'private' is chosen, the value for lb_subnet_type must be either 'internal' or 'both'"
  # values: public, internal. 
  # When creating an internal load balancer, the internal annotation must still be specified regardless 
  default = "public"
  type    = string
}

# ocir

variable "create_auth_token" {
  description = "whether to create an auth token to use with OCIR"
  default     = false
  type        = bool
}

variable "email_address" {
  description = "email address used for OCIR"
  type        = string
}

variable "ocir_urls" {
  # Region and region codes: https://docs.cloud.oracle.com/iaas/Content/General/Concepts/regions.htm#ServiceAvailabilityAcrossRegions
  description = "urls of ocir"
  default = {
    ap-sydney-1    = "syd.ocir.io"
    ap-melbourne-1 = "mel.ocir.io"
    ap-mumbai-1    = "bom.ocir.io"
    ap-osaka-1     = "kix.ocir.io"
    ap-seoul-1     = "icn.ocir.io"
    ap-tokyo-1     = "nrt.ocir.io"
    ca-toronto-1   = "yyz.ocir.io"
    eu-amsterdam-1 = "ams.ocir.io"
    eu-frankfurt-1 = "fra.ocir.io"
    eu-zurich-1    = "zrh.ocir.io"
    me-jeddah-1    = "jed.ocir.io"
    sa-saopaulo-1  = "gru.ocir.io"
    uk-london-1    = "lhr.ocir.io"
    us-ashburn-1   = "iad.ocir.io"
    us-phoenix-1   = "phx.ocir.io"
  }
  type = map(string)
}

variable "tenancy_name" {
  description = "tenancy name to use when creating the ocir secret"
  type        = string
}

variable "username" {
  description = "username to access OCIR"
  type        = string
}

# helm
variable "helm_version" {
  description = "version of helm to install"
  default     = "3.0.0"
  type        = string
}

variable "install_helm" {
  description = "whether to install helm client on the bastion"
  default     = false
  type        = bool
}

# calico
variable "calico_version" {
  description = "version of calico to install"
  default     = "3.9"
  type        = string
}

variable "install_calico" {
  description = "whether to install calico for network pod security policy"
  default     = false
  type        = bool
}

variable "install_metricserver" {
  description = "whether to install metricserver for collecting metrics and for HPA"
  default     = false
  type        = bool
}

# kms

variable "use_encryption" {
  description = "whether to use OCI Key Management to encrypt data"
  default     = false
  type        = bool
}

variable "existing_key_id" {
  description = "id of existing key"
  type        = string
}

# serviceaccount

variable "create_service_account" {
  description = "whether to create a service account. A service account is required for CI/CD. see https://docs.cloud.oracle.com/iaas/Content/ContEng/Tasks/contengaddingserviceaccttoken.htm"
  default     = false
  type        = bool
}

variable "service_account_name" {
  description = "name of service account to create"
  default     = "kubeconfigsa"
  type        = string
}

variable "service_account_namespace" {
  description = "kubernetes namespace where to create the service account"
  default     = "kube-system"
  type        = string
}

variable "service_account_cluster_role_binding" {
  description = "cluster role binding name"
  type        = string
}

# waf

variable "enable_waf" {
  description = "whether to enable WAF monitoring of load balancers"
  type        = bool
  default     = false
}
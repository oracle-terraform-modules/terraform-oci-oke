# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Identity and access parameters
variable "api_fingerprint" {
  description = "Fingerprint of oci api private key."
  type        = string
}

variable "api_private_key_path" {
  description = "The path to oci api private key."
  type        = string
}

variable "region" {
  # List of regions: https://docs.cloud.oracle.com/iaas/Content/General/Concepts/regions.htm#ServiceAvailabilityAcrossRegions
  description = "The oci region where resources will be created."
  type        = string
}

variable "tenancy_id" {
  description = "The tenancy id in which to create the sources."
  type        = string
}

variable "user_id" {
  description = "The id of the user that terraform will use to create the resources."
  type        = string
}

# general oci parameters
variable "compartment_id" {
  description = "The compartment id where to create all resources."
  type        = string
}

variable "label_prefix" {
  default     = "none"
  description = "A string that will be prepended to all resources."
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

# networking parameters
variable "nat_gateway_enabled" {
  default     = true
  description = "Whether to create a nat gateway in the vcn."
  type        = bool
}

variable "netnum" {
  description = "0-based index of the subnet when the network is masked with the newbit. Used as netnum parameter for cidrsubnet function."
  default = {
    bastion  = 32
    int_lb   = 16
    operator = 33
    pub_lb   = 17
    workers  = 1
  }
  type = map
}

variable "newbits" {
  default = {
    bastion  = 13
    lb       = 11
    operator = 13
    workers  = 2
  }
  description = "The masks for the subnets within the virtual network. Used as newbits parameter for cidrsubnet function."
  type        = map
}

variable "vcn_cidr" {
  default     = "10.0.0.0/16"
  description = "The cidr block of VCN."
  type        = string
}

variable "vcn_dns_label" {
  default     = "oke"
  description = "A DNS label for the VCN, used in conjunction with the VNIC's hostname and subnet's DNS label to form a fully qualified domain name (FQDN) for each VNIC within this subnet."
  type        = string
}

variable "vcn_name" {
  default     = "oke-vcn"
  description = "name of vcn"
  type        = string
}

# bastion
variable "bastion_access" {
  default     = "ANYWHERE"
  description = "The cidr from where the bastion can be sshed into. default is ANYWHERE and equivalent to 0.0.0.0/0."
  type        = string
}

variable "bastion_enabled" {
  default     = true
  description = "Whether to create a bastion host."
  type        = bool
}

variable "bastion_image_id" {
  default     = "Autonomous"
  description = "The image id to use for bastion."
  type        = string
}

variable "bastion_notification_enabled" {
  default     = false
  description = "Whether to enable notification on the bastion host."
  type        = bool
}

variable "bastion_notification_endpoint" {
  default     = "none"
  description = "The subscription notification endpoint for the bastion. The email address to be notified."
  type        = string
}

variable "bastion_notification_protocol" {
  default     = "EMAIL"
  description = "The notification protocol used."
  type        = string
}

variable "bastion_notification_topic" {
  default     = "bastion"
  description = "The name of the notification topic."
  type        = string
}

variable "bastion_package_upgrade" {
  default     = true
  description = "Whether to upgrade the bastion host packages after provisioning. it’s useful to set this to false during development so the bastion is provisioned faster."
  type        = bool
}

variable "bastion_shape" {
  default     = "VM.Standard.E2.1"
  description = "The shape of bastion instance."
  type        = string
}

variable "bastion_timezone" {
  default     = "Australia/Sydney"
  description = "The preferred timezone for the bastion host."
  type        = string
}

# operator

variable "operator_enabled" {
  default     = true
  description = "Whether to create an operator server in a private subnet."
  type        = bool
}

variable "operator_image_id" {
  default     = "Oracle"
  description = "The image id to use for operator server. Set either an image id or to Oracle. If value is set to Oracle, the default Oracle Linux platform image will be used."
  type        = string
}

variable "operator_instance_principal" {
  default     = true
  description = "Whether to enable the operator to call OCI API services without requiring api key."
  type        = bool
}

variable "operator_notification_enabled" {
  default     = false
  description = "Whether to enable notification on the operator host."
  type        = bool
}

variable "operator_notification_endpoint" {
  default     = "none"
  description = "The subscription notification endpoint for the operator. Email address to be notified."
  type        = string
}

variable "operator_notification_protocol" {
  default     = "EMAIL"
  description = "The notification protocol used."
  type        = string
}

variable "operator_notification_topic" {
  description = "The name of the notification topic."
  default     = "operator"
  type        = string
}

variable "operator_package_upgrade" {
  default     = true
  description = "Whether to upgrade the operator packages after provisioning. It’s useful to set this to false during development so the operator is provisioned faster."
  type        = bool
}

variable "operator_shape" {
  default     = "VM.Standard.E2.1"
  description = "The shape of operator instance."
  type        = string
}

variable "operator_timezone" {
  default     = "Australia/Sydney"
  description = "The preferred timezone for the operator host."
  type        = string
}

# availability domains
variable "availability_domains" {
  description = "Availability Domains where to provision non-OKE resources"
  default = {
    bastion  = 1
    operator = 1
  }
  type = map
}

# oke

variable "allow_node_port_access" {
  default     = false
  description = "Whether to allow access to NodePorts when worker nodes are deployed in public mode."
  type        = bool
}

variable "allow_worker_ssh_access" {
  default     = false
  description = "Whether to allow ssh access to worker nodes when worker nodes are deployed in public mode."
  type        = bool
}

variable "cluster_name" {
  default     = "oke"
  description = "The name of oke cluster."
  type        = string
}

variable "check_node_active" {
  description = "check worker node is active"
  type        = string
  default     = "none"
}

variable "dashboard_enabled" {
  default     = false
  description = "Whether to enable kubernetes dashboard."
  type        = bool
}

variable "kubernetes_version" {
  default     = "LATEST"
  description = "The version of kubernetes to use when provisioning OKE or to upgrade an existing OKE cluster to."
  type        = string
}

variable "node_pools" {
  default = {
    np1 = ["VM.Standard.E2.2", 1]
    np2 = ["VM.Standard2.8", 2]
    np3 = ["VM.Standard.E2.2", 1]

  }
  description = "Tuple of node pools. Each key maps to a node pool. Each value is a tuple of shape (string) and size(number)."
  type        = map(any)
}

variable "node_pools_to_drain" {
  default     = ["none"]
  description = "List of node pool names to upgrade. This list is used to determine the worker nodes to drain."
  type        = list(string)
}

variable "nodepool_drain" {
  default     = false
  description = "Whether to upgrade the Kubernetes version of the node pools."
  type        = bool
}

variable "nodepool_upgrade_method" {
  default     = "out_of_place"
  description = "The upgrade method to use when upgrading to a new version. Only out-of-place supported at the moment."
  type        = string
}

variable "node_pool_name_prefix" {
  default     = "np"
  description = "The prefix of the node pool name."
  type        = string
}

variable "node_pool_image_id" {
  default     = "none"
  description = "The ocid of a custom image to use for worker node."
  type        = string
}

variable "node_pool_os" {
  default     = "Oracle Linux"
  description = "The name of image to use."
  type        = string
}

variable "node_pool_os_version" {
  default     = "7.8"
  description = "The version of image Operating System to use."
  type        = string
}

variable "pods_cidr" {
  default     = "10.244.0.0/16"
  description = "The CIDR range used for IP addresses by the pods. A /16 CIDR is generally sufficient. This CIDR should not overlap with any subnet range in the VCN (it can also be outside the VCN CIDR range)."
  type        = string
}

variable "services_cidr" {
  default     = "10.96.0.0/16"
  description = "The CIDR range used by exposed Kubernetes services (ClusterIPs). This CIDR should not overlap with the VCN CIDR range."
  type        = string
}

variable "worker_mode" {
  default     = "private"
  description = "Whether to provision public or private workers."
  type        = string
}

# oke load balancers

variable "lb_subnet_type" {
  # values: both, internal, public
  default     = "public"
  description = "The type of load balancer subnets to create."
  type        = string
}

variable "preferred_lb_subnets" {
  # values: public, internal. 
  # When creating an internal load balancer, the internal annotation must still be specified regardless 
  default     = "public"
  description = "The preferred load balancer subnets that OKE will automatically choose when creating a load balancer. valid values are public or internal. if 'public' is chosen, the value for lb_subnet_type must be either 'public' or 'both'. If 'private' is chosen, the value for lb_subnet_type must be either 'internal' or 'both'."
  type        = string
}

# ocir
variable "secret_id" {
  description = "OCID of Oracle Vault Secret"
  type        =  string
  default     = "none"
}

variable "email_address" {
  default     = "none"
  description = "The email address used for OCIR."
  type        = string
}

variable "ocir_urls" {
  # Region and region codes: https://docs.cloud.oracle.com/iaas/Content/General/Concepts/regions.htm#ServiceAvailabilityAcrossRegions
  description = "The urls of ocir in the respective regions."
  default = {
    ap-chuncheon-1 = "yny.ocir.io"
    ap-hyderabad-1 = "hyd.ocir.io"
    ap-melbourne-1 = "mel.ocir.io"
    ap-mumbai-1    = "bom.ocir.io"
    ap-osaka-1     = "kix.ocir.io"
    ap-seoul-1     = "icn.ocir.io"
    ap-sydney-1    = "syd.ocir.io"
    ap-tokyo-1     = "nrt.ocir.io"
    ca-montreal-1  = "yul.ocir.io"
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
  default     = "none"
  description = "The tenancy name to use when creating the ocir secret."
  type        = string
}

variable "username" {
  default     = "none"
  description = "The username to access OCIR."
  type        = string
}

# helm
variable "helm_enabled" {
  description = "Whether to install helm client on the bastion."
  default     = false
  type        = bool
}

variable "helm_version" {
  default     = "3.2.4"
  description = "The version of helm to install."
  type        = string
}

# calico
variable "calico_enabled" {
  description = "whether to install calico for network pod security policy"
  default     = false
  type        = bool
}

variable "calico_version" {
  description = "The version of calico to install"
  default     = "3.12"
  type        = string
}

# metrics server
variable "metricserver_enabled" {
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

variable "waf_enabled" {
  description = "whether to enable WAF monitoring of load balancers"
  type        = bool
  default     = false
}

# tagging
variable "tags" {
  default = {
    # vcn, bastion and operator tags are required
    # add more tags in each as desired
    vcn = {
      # department = "finance"
      environment = "dev"
    }
    bastion = {
      # department  = "finance"
      environment = "dev"
      role        = "bastion"
    }
    operator = {
      # department = "finance"
      environment = "dev"
      role        = "operator"
    }
  }
  description = "Tags to apply to different resources."
  type        = map(any)
}

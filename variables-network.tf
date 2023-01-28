# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

variable "create_vcn" {
  default     = true
  description = "Whether to create a Virtual Cloud Network."
  type        = bool
}

variable "create_nsgs" {
  default     = true
  description = "Whether to create standard network security groups."
  type        = bool
}

variable "vcn_name" {
  default     = "oke"
  description = "Name of created VCN when `create_vcn = true`, or optional filter when `create_vcn = false`."
  type        = string
}

variable "vcn_id" {
  default     = null
  description = "Optional ID of existing VCN. Takes priority over vcn_name filter. Ignored when `create_vcn = true`."
  type        = string
}

variable "internet_gateway_display_name" {
  default     = null
  description = "Optional name of existing internet gateway if > 1 in VCN."
  type        = string
}

variable "ig_route_table_id" {
  default     = null
  description = "Optional ID of existing internet gateway in VCN."
  type        = string
}

variable "nat_gateway_display_name" {
  default     = null
  description = "Optional name of existing NAT gateway if > 1 in VCN."
  type        = string
}

variable "nat_route_table_id" {
  default     = null
  description = "Optional ID of existing NAT gateway in VCN."
  type        = string
}

variable "create_drg" {
  default     = false
  description = "whether to create Dynamic Routing Gateway. If set to true, creates a Dynamic Routing Gateway and attach it to the VCN."
  type        = bool
}

variable "drg_display_name" {
  default     = "drg"
  description = "(Updatable) Name of Dynamic Routing Gateway. Does not have to be unique."
  type        = string
}

variable "drg_id" {
  default     = null
  description = "ID of an external created Dynamic Routing Gateway to be attached to the VCN."
  type        = string
}

variable "internet_gateway_route_rules" {
  default     = null
  description = "(Updatable) List of routing rules to add to Internet Gateway Route Table."
  type        = list(map(string))
}

variable "local_peering_gateways" {
  default     = null
  description = "Map of Local Peering Gateways to attach to the VCN."
  type        = map(any)
}

variable "lockdown_default_seclist" {
  default     = true
  description = "Whether to remove all default security rules from the VCN Default Security List."
  type        = bool
}

variable "nat_gateway_route_rules" {
  default     = null
  description = "(Updatable) List of routing rules to add to NAT Gateway Route Table."
  type        = list(map(string))
}

variable "nat_gateway_public_ip_id" {
  default     = null
  description = "OCID of reserved IP address for NAT gateway. The reserved public IP address needs to be manually created."
  type        = string
}

variable "subnets" {
  default = {
    bastion  = { create = "auto", netnum = 0, newbits = 13, id = "" }
    operator = { create = "auto", netnum = 1, newbits = 13, id = "" }
    cp       = { create = "auto", netnum = 2, newbits = 13, id = "" }
    int_lb   = { create = "auto", netnum = 16, newbits = 11, id = "" }
    pub_lb   = { create = "auto", netnum = 17, newbits = 11, id = "" }
    workers  = { create = "auto", netnum = 1, newbits = 2, id = "" }
    pods     = { create = "auto", netnum = 2, newbits = 2, id = "" }
    fss      = { create = "auto", netnum = 18, newbits = 11, id = "" }
  }
  description = "parameters to cidrsubnet function to calculate subnet masks within the VCN."
  type        = any
}

variable "vcn_cidrs" {
  default     = ["10.0.0.0/16"]
  description = "The list of IPv4 CIDR blocks the VCN will use."
  type        = list(string)
}

variable "vcn_dns_label" {
  default     = "oke"
  description = "A DNS label for the VCN, used in conjunction with the VNIC's hostname and subnet's DNS label to form a fully qualified domain name (FQDN) for each VNIC within this subnet. DNS resolution of hostnames in the VCN is disabled when null."
  type        = string
}

variable "assign_dns" {
  default     = true
  description = "Whether to assign DNS records to created instances."
  type        = bool
}

variable "allow_node_port_access" {
  default     = false
  description = "Whether to allow access from worker NodePort range to load balancers."
  type        = bool
}

variable "allow_worker_internet_access" {
  default     = true
  description = "Allow worker nodes to egress to internet. Required if container images are in a registry other than OCIR."
  type        = bool
}

variable "allow_pod_internet_access" {
  default     = true
  description = "Allow pods to egress to internet. Ignored when cni_type != 'npn'."
  type        = bool
}

variable "allow_worker_ssh_access" {
  default     = false
  description = "Whether to allow SSH access to worker nodes."
  type        = bool
}

variable "allow_rules_internal_lb" {
  default     = {}
  description = "A map of additional rules to allow incoming traffic for internal load balancers."
  type        = any
}

variable "allow_rules_public_lb" {
  default     = {}
  description = "A map of additional rules to allow incoming traffic for public load balancers."
  type        = any
}

variable "control_plane_allowed_cidrs" {
  default     = []
  description = "The list of CIDR blocks from which the control plane can be accessed."
  type        = list(string)
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

variable "enable_waf" {
  description = "Whether to enable WAF monitoring of load balancers."
  type        = bool
  default     = false
}

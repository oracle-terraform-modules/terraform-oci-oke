# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

variable "create_vcn" {
  default     = true
  description = "Whether to create a Virtual Cloud Network."
  type        = bool
}

variable "vcn_name" {
  default     = null
  description = "Display name for the created VCN. Defaults to 'oke' suffixed with the generated Terraform 'state_id' value."
  type        = string
}

variable "vcn_id" {
  default     = null
  description = "Optional ID of existing VCN. Takes priority over vcn_name filter. Ignored when `create_vcn = true`."
  type        = string
}

variable "vcn_create_nat_gateway" {
  default     = "auto"
  description = "Whether to create a NAT gateway with the VCN. Defaults to automatic creation when private network resources are expected to utilize it."
  type        = string
  validation {
    condition     = contains(["never", "auto", "always"], var.vcn_create_nat_gateway)
    error_message = "Accepted values are never, auto, or always"
  }
}

variable "vcn_create_internet_gateway" {
  default     = "auto"
  description = "Whether to create an internet gateway with the VCN. Defaults to automatic creation when public network resources are expected to utilize it."
  type        = string
  validation {
    condition     = contains(["never", "auto", "always"], var.vcn_create_internet_gateway)
    error_message = "Accepted values are never, auto, or always"
  }
}

variable "vcn_create_service_gateway" {
  default     = "always"
  description = "Whether to create a service gateway with the VCN. Defaults to always created."
  type        = string
  validation {
    condition     = contains(["never", "auto", "always"], var.vcn_create_service_gateway)
    error_message = "Accepted values are never, auto, or always"
  }
}

variable "vcn_enable_ipv6_gua" {
  default     = true
  description = "Whether to enable IPv6 GUA when IPv6 is enabled."
  type        = bool
}

variable "vcn_ipv6_ula_cidrs" {
  default     = []
  description = "IPv6 ULA CIDR blocks to be used for the VCN."
  type        = list(string)
}

variable "internet_gateway_id" {
  default     = null
  description = "Optional ID of existing Internet gateway in VCN."
  type        = string
}

variable "ig_route_table_id" {
  default     = null
  description = "Optional ID of existing internet gateway route table in VCN."
  type        = string
}

variable "nat_gateway_id" {
  default     = null
  description = "Optional ID of existing NAT gateway in VCN."
  type        = string
}

variable "nat_route_table_id" {
  default     = null
  description = "Optional ID of existing NAT gateway route table in VCN."
  type        = string
}

variable "igw_ngw_mixed_route_id" {
  default     = null
  description = "Optional ID of the existing route table in VCN using IGW for IPv6 and NGW for IPv4."
  type        = string
}

variable "create_drg" {
  default     = false
  description = "Whether to create a Dynamic Routing Gateway and attach it to the VCN."
  type        = bool
}

variable "drg_display_name" {
  default     = null
  description = "(Updatable) Name of the created Dynamic Routing Gateway. Does not have to be unique. Defaults to 'oke' suffixed with the generated Terraform 'state_id' value."
  type        = string
}

variable "drg_id" {
  default     = null
  description = "ID of an external created Dynamic Routing Gateway to be attached to the VCN."
  type        = string
}

variable "drg_compartment_id" {
  default     = null
  description = "Compartment for the DRG resource. Can be used to override network_compartment_id."
  type        = string
}

variable "drg_attachments" {
  description = "DRG attachment configurations."
  type        = any
  default     = {}
}

variable "remote_peering_connections" {
  description = "Map of parameters to add and optionally to peer to remote peering connections. Key-only items represent local acceptors and no peering attempted; items containing key and values represent local requestor and must have the OCID and region of the remote acceptor to peer to"
  type        = map(any)
  default     = {}
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
    bastion  = { newbits = 13, ipv6_cidr = "8, 0" }
    operator = { newbits = 13, ipv6_cidr = "8, 1" }
    cp       = { newbits = 13, ipv6_cidr = "8, 2" }
    int_lb   = { newbits = 11, ipv6_cidr = "8, 3" }
    pub_lb   = { newbits = 11, ipv6_cidr = "8, 4" }
    workers  = { newbits = 4, ipv6_cidr = "8, 5" }
    pods     = { newbits = 2, ipv6_cidr = "8, 6" }
  }
  description = "Configuration for standard subnets. The 'create' parameter of each entry defaults to 'auto', creating subnets when other enabled components are expected to utilize them, and may be configured with 'never' or 'always' to force disabled/enabled."
  type = map(object({
    create       = optional(string)
    id           = optional(string)
    newbits      = optional(string)
    netnum       = optional(string)
    cidr         = optional(string)
    display_name = optional(string)
    dns_label    = optional(string)
    ipv6_cidr    = optional(string)
  }))
  validation {
    condition = alltrue([
      for k, v in var.subnets : contains(["never", "auto", "always"], coalesce(v.create, "auto"))
    ])
    error_message = "Accepted values for 'create' are 'never', 'auto', or 'always'."
  }
  validation {
    condition = alltrue([
      for v in flatten([for k, v in var.subnets : keys(v)]) : contains(["create", "id", "cidr", "netnum", "newbits", "display_name", "dns_label", "ipv6_cidr"], v)
    ])
    error_message = format("Invalid subnet configuration keys: %s", jsonencode(distinct([
      for v in flatten([for k, v in var.subnets : keys(v)]) : v if !contains(["create", "id", "cidr", "netnum", "newbits", "display_name", "dns_label", "ipv6_cidr"], v)
    ])))
  }
}

variable "nsgs" {
  default = {
    bastion  = {}
    operator = {}
    cp       = {}
    int_lb   = {}
    pub_lb   = {}
    workers  = {}
    pods     = {}
  }
  description = "Configuration for standard network security groups (NSGs).  The 'create' parameter of each entry defaults to 'auto', creating NSGs when other enabled components are expected to utilize them, and may be configured with 'never' or 'always' to force disabled/enabled."
  type = map(object({
    create = optional(string)
    id     = optional(string)
  }))
  validation {
    condition = alltrue([
      for k, v in values(var.nsgs) : contains(["never", "auto", "always"], coalesce(v.create, "auto"))
    ])
    error_message = "Accepted values for 'create' are 'never', 'auto', or 'always'."
  }
  validation {
    condition = alltrue([
      for v in flatten([for k, v in var.nsgs : keys(v)]) : contains(["create", "id"], v)
    ])
    error_message = format("Invalid NSG configuration keys: %s", jsonencode(distinct([
      for v in flatten([for k, v in var.nsgs : keys(v)]) : v if !contains(["create", "id"], v)
    ])))
  }
  validation {
    condition = alltrue([
      for k, v in var.nsgs :
      contains(["bastion", "operator", "cp", "int_lb", "pub_lb", "workers", "pods", "fss"], k)
    ])
    error_message = format("Invalid NSG keys: %s", jsonencode([for k, v in var.nsgs : k
      if !contains(["bastion", "operator", "cp", "int_lb", "pub_lb", "workers", "pods", "fss"], k)
    ]))
  }
}

variable "vcn_cidrs" {
  default     = ["10.0.0.0/16"]
  description = "The list of IPv4 CIDR blocks the VCN will use."
  type        = list(string)
}

variable "vcn_dns_label" {
  default     = null
  description = "A DNS label for the VCN, used in conjunction with the VNIC's hostname and subnet's DNS label to form a fully qualified domain name (FQDN) for each VNIC within this subnet. Defaults to the generated Terraform 'state_id' value."
  type        = string
}

variable "assign_dns" {
  default     = true
  description = "Whether to assign DNS records to created instances or disable DNS resolution of hostnames in the VCN."
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

variable "allow_bastion_cluster_access" {
  default     = false
  description = "Whether to allow access to the Kubernetes cluster endpoint from the bastion host."
  type        = bool
}

variable "allow_rules_cp" {
  default     = {}
  description = "A map of additional rules to allow traffic for the OKE control plane."
  type        = any
}

variable "allow_rules_internal_lb" {
  default     = {}
  description = "A map of additional rules to allow incoming traffic for internal load balancers."
  type        = any
}

variable "allow_rules_pods" {
  default     = {}
  description = "A map of additional rules to allow traffic for the pods."
  type        = any
}

variable "allow_rules_public_lb" {
  default     = {}
  description = "A map of additional rules to allow incoming traffic for public load balancers."
  type        = any
}

variable "allow_rules_workers" {
  default     = {}
  description = "A map of additional rules to allow traffic for the workers."
  type        = any
}

variable "control_plane_allowed_cidrs" {
  default     = []
  description = "The list of CIDR blocks from which the control plane can be accessed."
  type        = list(string)
}

variable "enable_waf" {
  description = "Whether to enable WAF monitoring of load balancers."
  type        = bool
  default     = false
}


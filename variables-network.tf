# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

variable "create_vcn" {
  default     = true
  description = "Whether to create a Virtual Cloud Network."
  type        = bool
}

variable "create_nsgs" { // TODO Align with subnets declaration in map
  default     = true
  description = "Whether to create standard network security groups."
  type        = bool
}

variable "create_nsgs_always" { // TODO Align with subnets declaration, never/auto/always
  default     = false
  description = "Whether to create standard network security groups when associated components will not be."
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

variable "ig_route_table_id" {
  default     = null
  description = "Optional ID of existing internet gateway in VCN."
  type        = string
}

variable "nat_route_table_id" {
  default     = null
  description = "Optional ID of existing NAT gateway in VCN."
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
    bastion  = { create = "auto", newbits = 13 }
    operator = { create = "auto", newbits = 13 }
    cp       = { create = "auto", newbits = 13 }
    int_lb   = { create = "auto", newbits = 11 }
    pub_lb   = { create = "auto", newbits = 11 }
    workers  = { create = "auto", newbits = 2 }
    pods     = { create = "auto", newbits = 2 }
    fss      = { create = "auto", newbits = 11 }
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

variable "enable_waf" {
  description = "Whether to enable WAF monitoring of load balancers."
  type        = bool
  default     = false
}

variable "drg_attachments" {
  description = "DRG attachment configurations."
  type        = any
  default     = {}
}
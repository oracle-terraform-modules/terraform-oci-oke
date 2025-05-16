# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Common
variable "compartment_id" { type = string }
variable "state_id" { type = string }

# Tags
variable "defined_tags" { type = map(string) }
variable "freeform_tags" { type = map(string) }
variable "tag_namespace" { type = string }
variable "use_defined_tags" { type = bool }

# Network
variable "allow_node_port_access" { type = bool }
variable "allow_pod_internet_access" { type = bool }
variable "allow_rules_cp" { type = any }
variable "allow_rules_internal_lb" { type = any }
variable "allow_rules_pods" { type = any }
variable "allow_rules_public_lb" { type = any }
variable "allow_rules_workers" { type = any }
variable "allow_worker_internet_access" { type = bool }
variable "allow_worker_ssh_access" { type = bool }
variable "allow_bastion_cluster_access" { type = bool }
variable "assign_dns" { type = bool }
variable "bastion_allowed_cidrs" { type = set(string) }
variable "bastion_is_public" { type = bool }
variable "cni_type" { type = string }
variable "control_plane_allowed_cidrs" { type = set(string) }
variable "control_plane_is_public" { type = bool }
variable "create_cluster" { type = bool }
variable "create_bastion" { type = bool }
variable "create_internet_gateway" { type = bool }
variable "create_nat_gateway" { type = bool }
variable "create_operator" { type = bool }
variable "drg_attachments" { type = any }
variable "enable_ipv6" { type = bool }
variable "enable_waf" { type = bool }
variable "ig_route_table_id" { type = string }
variable "igw_ngw_mixed_route_id" { type = string }
variable "internet_gateway_id" { type = string }
variable "load_balancers" { type = string }
variable "nat_gateway_id" { type = string }
variable "nat_route_table_id" { type = string }
variable "vcn_cidrs" { type = list(string) }
variable "vcn_ipv6_cidr" { type = string }
variable "vcn_id" { type = string }
variable "worker_is_public" { type = bool }

variable "subnets" {
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
}

variable "nsgs" {
  type = map(object({
    create = optional(string)
    id     = optional(string)
  }))
}

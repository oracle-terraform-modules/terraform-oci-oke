# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

data "oci_core_vcn" "oke" {
  count  = var.create_vcn ? 0 : 1
  vcn_id = coalesce(var.vcn_id, "none")
}

locals {
  # Created VCN if enabled, else var.vcn_id
  vcn_id = var.create_vcn ? try(one(module.vcn[*].vcn_id), var.vcn_id) : var.vcn_id

  # Configured VCN CIDRs if creating, else from provided vcn_id
  vcn_lookup             = coalesce(one(data.oci_core_vcn.oke[*].cidr_blocks), [])
  vcn_lookup_cidr_blocks = flatten(local.vcn_lookup)
  vcn_cidrs              = var.create_vcn ? var.vcn_cidrs : local.vcn_lookup_cidr_blocks
  vcn_ipv6_cidr          = var.create_vcn ? one(try(coalescelist(module.vcn[0].vcn_all_attributes["ipv6cidr_blocks"], module.vcn[0].vcn_all_attributes["byoipv6cidr_blocks"], module.vcn[0].vcn_all_attributes["ipv6private_cidr_blocks"]), [])) : one(try(coalescelist(data.oci_core_vcn.oke[0].ipv6cidr_blocks, data.oci_core_vcn.oke[0].byoipv6cidr_blocks, data.oci_core_vcn.oke[0].ipv6private_cidr_blocks), []))
  # Created route table if enabled, else var.ig_route_table_id
  ig_route_table_id = var.create_vcn ? try(one(module.vcn[*].ig_route_id), var.ig_route_table_id) : var.ig_route_table_id

  # Created route table if enabled, else var.nat_route_table_id
  nat_route_table_id = var.create_vcn ? try(one(module.vcn[*].nat_route_id), var.ig_route_table_id) : var.nat_route_table_id

  create_internet_gateway = alltrue([
    var.vcn_create_internet_gateway != "never",    # always disable
    anytrue([                                      # enable for configurations that generally utilize it
      var.vcn_create_internet_gateway == "always", # always enable
      var.create_bastion && var.bastion_is_public, # enable for public bastion
      var.control_plane_is_public,                 # enable for cluster w/ public endpoint
      var.load_balancers != "internal",            # enable for cluster w/ public load balancers
    ])
  ])

  create_nat_gateway = alltrue([
    var.vcn_create_nat_gateway != "never",                # always disable
    anytrue([                                             # enable for configurations that generally utilize it
      var.vcn_create_nat_gateway == "always",             # always enable
      !var.worker_is_public,                              # enable for private workers
      var.create_operator,                                # enable for operator
      !var.control_plane_is_public,                       # enable for cluster w/ private endpoint
      contains(["internal", "both"], var.load_balancers), # enable for cluster w/ private load balancers
    ])
  ])

  internet_gateway_id = var.create_vcn ? try(one(module.vcn[*].internet_gateway_id), var.internet_gateway_id) : var.internet_gateway_id
  nat_gateway_id      = var.create_vcn ? try(one(module.vcn[*].nat_gateway_id), var.nat_gateway_id) : var.nat_gateway_id
}

module "vcn" {
  count          = var.create_vcn ? 1 : 0
  source         = "oracle-terraform-modules/vcn/oci"
  version        = "3.6.0"
  compartment_id = coalesce(var.network_compartment_id, local.compartment_id)

  # Standard tags as defined if enabled for use, or freeform
  # User-provided tags are merged last and take precedence
  defined_tags = merge(var.use_defined_tags ? {
    "${var.tag_namespace}.state_id" = local.state_id,
    "${var.tag_namespace}.role"     = "network",
    } : {},
    local.network_defined_tags,
  )
  freeform_tags = merge(var.use_defined_tags ? {} : {
    "state_id" = local.state_id,
    "role"     = "network",
    },
    local.network_freeform_tags,
  )

  attached_drg_id = var.drg_id != null ? var.drg_id : (tobool(var.create_drg) ? module.drg[0].drg_id : null)

  create_internet_gateway = local.create_internet_gateway

  create_nat_gateway = local.create_nat_gateway

  create_service_gateway       = var.vcn_create_service_gateway != "never"
  internet_gateway_route_rules = var.internet_gateway_route_rules
  local_peering_gateways       = var.local_peering_gateways
  lockdown_default_seclist     = var.lockdown_default_seclist
  nat_gateway_public_ip_id     = var.nat_gateway_public_ip_id
  nat_gateway_route_rules      = var.nat_gateway_route_rules

  enable_ipv6   = var.enable_ipv6
  vcn_cidrs     = local.vcn_cidrs
  vcn_dns_label = var.assign_dns ? coalesce(var.vcn_dns_label, local.state_id) : null
  vcn_name      = coalesce(var.vcn_name, "oke-${local.state_id}")
}

module "drg" {
  count              = tobool(var.create_drg) || var.drg_id != null ? 1 : 0
  source             = "oracle-terraform-modules/drg/oci"
  version            = "1.0.6"
  compartment_id     = coalesce(var.network_compartment_id, local.compartment_id)
  drg_compartment_id = var.drg_compartment_id

  drg_id           = one([var.drg_id]) # existing DRG ID or null
  drg_display_name = coalesce(var.drg_display_name, "oke-${local.state_id}")
  drg_vcn_attachments = tobool(var.create_drg) || var.drg_id != null ? { for k, v in module.vcn : k => {
    # gets the vcn_id values dynamically from the vcn module 
    vcn_id : v.vcn_id
    vcn_transit_routing_rt_id : null
    drg_route_table_id : null
    }
  } : var.drg_attachments

  # rpc parameters
  remote_peering_connections = { for k, v in var.remote_peering_connections : k => {
    "rpc_acceptor_id"     = try(v.rpc_acceptor_id, null),
    "rpc_acceptor_region" = try(v.rpc_acceptor_region, null)
    }
  }
}

module "network" {
  source           = "./modules/network"
  state_id         = local.state_id
  compartment_id   = coalesce(var.network_compartment_id, local.compartment_id)
  defined_tags     = local.network_defined_tags
  freeform_tags    = local.network_freeform_tags
  tag_namespace    = var.tag_namespace
  use_defined_tags = var.use_defined_tags

  allow_node_port_access       = var.allow_node_port_access
  allow_pod_internet_access    = var.allow_pod_internet_access
  allow_rules_cp               = var.allow_rules_cp
  allow_rules_internal_lb      = var.allow_rules_internal_lb
  allow_rules_pods             = var.allow_rules_pods
  allow_rules_public_lb        = var.allow_rules_public_lb
  allow_rules_workers          = var.allow_rules_workers
  allow_worker_internet_access = var.allow_worker_internet_access
  allow_worker_ssh_access      = var.allow_worker_ssh_access
  allow_bastion_cluster_access = var.allow_bastion_cluster_access
  assign_dns                   = var.assign_dns
  bastion_allowed_cidrs        = var.bastion_allowed_cidrs
  bastion_is_public            = var.bastion_is_public
  cni_type                     = var.cni_type
  control_plane_allowed_cidrs  = var.control_plane_allowed_cidrs
  control_plane_is_public      = var.control_plane_is_public
  create_cluster               = var.create_cluster
  create_bastion               = var.create_bastion
  create_internet_gateway      = local.create_internet_gateway
  create_nat_gateway           = local.create_nat_gateway
  enable_ipv6                  = var.enable_ipv6
  nsgs                         = var.nsgs
  create_operator              = local.operator_enabled
  drg_attachments              = var.drg_attachments
  enable_waf                   = var.enable_waf
  ig_route_table_id            = local.ig_route_table_id
  igw_ngw_mixed_route_id       = var.igw_ngw_mixed_route_id
  internet_gateway_id          = local.internet_gateway_id
  load_balancers               = var.load_balancers
  nat_gateway_id               = local.nat_gateway_id
  nat_route_table_id           = local.nat_route_table_id
  subnets                      = var.subnets
  vcn_cidrs                    = local.vcn_cidrs
  vcn_ipv6_cidr                = local.vcn_ipv6_cidr
  vcn_id                       = local.vcn_id
  worker_is_public             = var.worker_is_public
}

# VCN
output "vcn_id" {
  description = "VCN ID"
  value       = try(local.vcn_id, null)
}
output "ig_route_table_id" {
  description = "Internet gateway route table ID"
  value       = try(local.ig_route_table_id, null)
}
output "nat_route_table_id" {
  description = "NAT gateway route table ID"
  value       = try(local.nat_route_table_id, null)
}

# Subnets
output "bastion_subnet_id" {
  value = try(module.network.bastion_subnet_id, null)
}
output "bastion_subnet_cidr" {
  value = try(module.network.bastion_subnet_cidr, null)
}
output "operator_subnet_id" {
  value = try(module.network.operator_subnet_id, null)
}
output "operator_subnet_cidr" {
  value = try(module.network.operator_subnet_cidr, null)
}
output "control_plane_subnet_id" {
  value = try(module.network.control_plane_subnet_id, null)
}
output "control_plane_subnet_cidr" {
  value = try(module.network.control_plane_subnet_cidr, null)
}
output "worker_subnet_id" {
  value = try(module.network.worker_subnet_id, null)
}
output "worker_subnet_cidr" {
  value = try(module.network.worker_subnet_cidr, null)
}
output "pod_subnet_id" {
  value = try(module.network.pod_subnet_id, null)
}
output "pod_subnet_cidr" {
  value = try(module.network.pod_subnet_cidr, null)
}
output "int_lb_subnet_id" {
  value = try(module.network.int_lb_subnet_id, null)
}
output "int_lb_subnet_cidr" {
  value = try(module.network.int_lb_subnet_cidr, null)
}
output "pub_lb_subnet_id" {
  value = try(module.network.pub_lb_subnet_id, null)
}
output "pub_lb_subnet_cidr" {
  value = try(module.network.pub_lb_subnet_cidr, null)
}
output "fss_subnet_id" {
  value = try(module.network.fss_subnet_id, null)
}
output "fss_subnet_cidr" {
  value = try(module.network.fss_subnet_cidr, null)
}

# NSGs
output "bastion_nsg_id" {
  description = "Network Security Group for bastion host(s)."
  value       = try(module.network.bastion_nsg_id, null)
}
output "operator_nsg_id" {
  description = "Network Security Group for operator host(s)."
  value       = try(module.network.operator_nsg_id, null)
}
output "control_plane_nsg_id" {
  description = "Network Security Group for Kubernetes control plane(s)."
  value       = try(module.network.control_plane_nsg_id, null)
}
output "int_lb_nsg_id" {
  description = "Network Security Group for internal load balancers."
  value       = try(module.network.int_lb_nsg_id, null)
}
output "pub_lb_nsg_id" {
  description = "Network Security Group for public load balancers."
  value       = try(module.network.pub_lb_nsg_id, null)
}
output "worker_nsg_id" {
  description = "Network Security Group for worker nodes."
  value       = try(module.network.worker_nsg_id, null)
}
output "pod_nsg_id" {
  description = "Network Security Group for pods."
  value       = try(module.network.pod_nsg_id, null)
}
output "fss_nsg_id" {
  description = "Network Security Group for File Storage Service resources."
  value       = try(module.network.fss_nsg_id, null)
}

output "network_security_rules" {
  value = var.output_detail ? try(module.network.network_security_rules, null) : null
}

# DRG
# output "drg_id" {
#   description = "Dynamic routing gateway ID"
#   value       = try(one(module.drg[*].drg_id), null)
# }

# LPG
output "lpg_all_attributes" {
  description = "all attributes of created lpg"
  value       = try(one(module.vcn[*].lpg_all_attributes), null)
}
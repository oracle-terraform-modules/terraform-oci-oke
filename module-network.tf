# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

data "oci_core_vcns" "all" {
  count          = var.create_vcn ? 0 : 1
  compartment_id = local.compartment_id
  display_name   = var.vcn_name
  state          = "AVAILABLE"
}

data "oci_core_vcn" "oke" {
  count  = var.create_vcn ? 0 : 1
  vcn_id = var.vcn_id
}

data "oci_core_nat_gateways" "all" {
  compartment_id = local.compartment_id
  display_name   = var.nat_gateway_display_name
  state          = "AVAILABLE"
  vcn_id         = local.vcn_id
}

data "oci_core_internet_gateways" "all" {
  compartment_id = local.compartment_id
  display_name   = var.internet_gateway_display_name
  state          = "AVAILABLE"
  vcn_id         = local.vcn_id
}

data "oci_core_route_tables" "all" {
  compartment_id = local.compartment_id
  state          = "AVAILABLE"
  vcn_id         = local.vcn_id
}

locals {
  vcn_id = (var.create_vcn ? one(module.vcn[*].vcn_id)
    : coalesce(var.vcn_id, "none") != "none" ? var.vcn_id
    : one(one(data.oci_core_vcns.all[*].virtual_networks)[*].id)
  )

  # Created VCN if enabled -> var.vcn_id if provided -> discovered VCN if matched
  vcn_cidrs = coalescelist(var.vcn_cidrs, flatten(data.oci_core_vcn.oke[*].cidr_blocks))

  # Created route table if enabled -> var.ig_route_table_id if provided -> discovered route table if matched
  internet_gateways = data.oci_core_internet_gateways.all.gateways[*].id
  nat_gateways      = data.oci_core_nat_gateways.all.nat_gateways[*].id

  # Filter route tables associated with a matching internet gateway
  ig_route_tables = [for table in data.oci_core_route_tables.all.route_tables : table.id
    if anytrue([for rule in lookup(table, "route_rules", []) : contains(local.internet_gateways, rule.network_entity_id)])
  ]

  # Filter route tables associated with a matching NAT gateway
  nat_route_tables = [for table in data.oci_core_route_tables.all.route_tables : table.id
    if anytrue([for rule in lookup(table, "route_rules", []) : contains(local.nat_gateways, rule.network_entity_id)])
  ]

  # Created route table if enabled -> var.ig_route_table_id if provided -> discovered route table if matched
  ig_route_table_id = (var.create_vcn ? one(module.vcn[*].ig_route_id)
    : coalesce(var.ig_route_table_id, "none") != "none" ? var.ig_route_table_id
    : try(element(local.ig_route_tables, 1), null)
  )

  # Created route table if enabled -> var.nat_route_table_id if provided -> discovered route table if matched
  nat_route_table_id = (var.create_vcn ? one(module.vcn[*].nat_route_id)
    : coalesce(var.nat_route_table_id, "none") != "none" ? var.nat_route_table_id
    : try(element(local.nat_route_tables, 1), null)
  )
}

module "vcn" {
  count          = var.create_vcn ? 1 : 0
  source         = "oracle-terraform-modules/vcn/oci"
  version        = "3.5.3"
  compartment_id = coalesce(var.network_compartment_id, local.compartment_id)
  defined_tags   = var.defined_tags["vcn"]
  freeform_tags  = var.freeform_tags["vcn"]

  attached_drg_id              = var.drg_id != null ? var.drg_id : (var.create_drg ? module.drg[0].drg_id : null)
  create_internet_gateway      = !(var.load_balancers == "internal" && !var.create_bastion && var.control_plane_type == "private")
  create_nat_gateway           = var.worker_type == "private" || var.create_operator || var.load_balancers == "internal" || var.load_balancers == "both"
  create_service_gateway       = true
  internet_gateway_route_rules = var.internet_gateway_route_rules
  local_peering_gateways       = var.local_peering_gateways
  lockdown_default_seclist     = var.lockdown_default_seclist
  nat_gateway_public_ip_id     = var.nat_gateway_public_ip_id
  nat_gateway_route_rules      = var.nat_gateway_route_rules
  vcn_cidrs                    = local.vcn_cidrs
  vcn_dns_label                = var.assign_dns ? var.vcn_dns_label : null
  vcn_name                     = var.vcn_name
}

module "drg" {
  count          = var.create_drg || var.drg_id != null ? 1 : 0
  source         = "oracle-terraform-modules/drg/oci"
  version        = "1.0.3"
  compartment_id = coalesce(var.network_compartment_id, local.compartment_id)

  drg_id           = var.drg_id # existing DRG ID or null
  drg_display_name = var.drg_display_name
  drg_vcn_attachments = {
    (random_id.state_id.id) : {
      vcn_id                    = local.vcn_id
      vcn_transit_routing_rt_id = null
      drg_route_table_id        = null
    }
  }
}

module "network" {
  source           = "./modules/network"
  state_id         = random_id.state_id.id
  compartment_id   = coalesce(var.network_compartment_id, local.compartment_id)
  defined_tags     = lookup(var.defined_tags, "network", {})
  freeform_tags    = lookup(var.freeform_tags, "network", {})
  tag_namespace    = var.tag_namespace
  use_defined_tags = var.use_defined_tags

  allow_node_port_access       = var.allow_node_port_access
  allow_pod_internet_access    = var.allow_pod_internet_access
  allow_rules_internal_lb      = var.allow_rules_internal_lb
  allow_rules_public_lb        = var.allow_rules_public_lb
  allow_worker_internet_access = var.allow_worker_internet_access
  allow_worker_ssh_access      = var.allow_worker_ssh_access
  assign_dns                   = var.assign_dns
  bastion_allowed_cidrs        = var.bastion_allowed_cidrs
  bastion_type                 = var.bastion_type
  cni_type                     = var.cni_type
  control_plane_allowed_cidrs  = var.control_plane_allowed_cidrs
  control_plane_type           = var.control_plane_type
  create_bastion               = var.create_bastion
  create_fss                   = var.create_fss
  create_nsgs                  = var.create_nsgs
  create_operator              = local.operator_enabled
  enable_waf                   = var.enable_waf
  ig_route_table_id            = local.ig_route_table_id
  load_balancers               = var.load_balancers
  nat_route_table_id           = local.nat_route_table_id
  subnets                      = var.subnets
  vcn_cidrs                    = local.vcn_cidrs
  vcn_id                       = local.vcn_id
  worker_type                  = var.worker_type

  providers = {
    oci.home = oci.home
  }
}

output "ig_route_table_id" {
  description = "Internet gateway route table ID"
  value       = local.ig_route_table_id
}

output "nat_route_table_id" {
  description = "NAT gateway route table ID"
  value       = local.nat_route_table_id
}

output "nsg_ids" {
  description = "Map of network security group IDs by role for the cluster and associated resources."
  value = var.create_nsgs ? {
    "bastion"  = module.network.bastion_nsg_id
    "cp"       = module.network.cp_nsg_id
    "fss"      = module.network.fss_nsg_id
    "int_lb"   = module.network.int_lb_nsg_id
    "operator" = module.network.operator_nsg_id
    "pods"     = module.network.pod_nsg_id
    "pub_lb"   = module.network.pub_lb_nsg_id
    "workers"  = module.network.worker_nsg_id
  } : null
}

output "subnet_ids" {
  description = "Map of subnet ids by role for the cluster and associated resources."
  value       = module.network.subnet_ids
}

output "drg_id" {
  description = "Dynamic routing gateway ID"
  value       = one(module.drg[*].drg_id)
}

output "vcn_id" {
  description = "VCN ID"
  value       = local.vcn_id
}

output "network_security_rules" {
  value = var.output_network_detail ? module.network.network_security_rules : null
}

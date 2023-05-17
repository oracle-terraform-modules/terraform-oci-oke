# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

data "oci_core_vcn" "oke" {
  count  = coalesce(var.vcn_id, "none") != "none" ? 0 : 1
  vcn_id = coalesce(var.vcn_id, "none")
}

locals {
  # Created VCN if enabled, else var.vcn_id
  vcn_id = var.create_vcn ? one(module.vcn[*].vcn_id) : var.vcn_id

  # Configured VCN CIDRs if creating, else from provided vcn_id
  vcn_lookup             = coalesce(one(data.oci_core_vcn.oke[*].cidr_blocks), [])
  vcn_lookup_cidr_blocks = flatten(local.vcn_lookup)
  vcn_cidrs              = var.create_vcn ? var.vcn_cidrs : local.vcn_lookup_cidr_blocks

  # Created route table if enabled, else var.ig_route_table_id
  ig_route_table_id = var.create_vcn ? one(module.vcn[*].ig_route_id) : var.ig_route_table_id

  # Created route table if enabled, else var.nat_route_table_id
  nat_route_table_id = var.create_vcn ? one(module.vcn[*].nat_route_id) : var.nat_route_table_id
}

module "vcn" {
  count          = var.create_vcn ? 1 : 0
  source         = "oracle-terraform-modules/vcn/oci"
  version        = "3.5.3"
  compartment_id = coalesce(var.network_compartment_id, local.compartment_id)
  defined_tags   = var.defined_tags["vcn"]
  freeform_tags  = var.freeform_tags["vcn"]

  attached_drg_id = var.drg_id != null ? var.drg_id : (var.create_drg ? module.drg[0].drg_id : null)

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

  create_service_gateway       = var.vcn_create_service_gateway != "never"
  internet_gateway_route_rules = var.internet_gateway_route_rules
  local_peering_gateways       = var.local_peering_gateways
  lockdown_default_seclist     = var.lockdown_default_seclist
  nat_gateway_public_ip_id     = var.nat_gateway_public_ip_id
  nat_gateway_route_rules      = var.nat_gateway_route_rules
  vcn_cidrs                    = local.vcn_cidrs
  vcn_dns_label                = var.assign_dns ? coalesce(var.vcn_dns_label, local.state_id) : null
  vcn_name                     = coalesce(var.vcn_name, "oke-${local.state_id}")
}

module "drg" {
  count          = var.create_drg || var.drg_id != null ? 1 : 0
  source         = "oracle-terraform-modules/drg/oci"
  version        = "1.0.3"
  compartment_id = coalesce(var.network_compartment_id, local.compartment_id)

  drg_id              = var.drg_id # existing DRG ID or null
  drg_display_name    = coalesce(var.drg_display_name, "oke-${local.state_id}")
  drg_vcn_attachments = var.drg_attachments
}

module "network" {
  source           = "./modules/network"
  state_id         = local.state_id
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
  allow_bastion_cluster_access = var.allow_bastion_cluster_access
  assign_dns                   = var.assign_dns
  bastion_allowed_cidrs        = var.bastion_allowed_cidrs
  bastion_is_public            = var.bastion_is_public
  cni_type                     = var.cni_type
  control_plane_allowed_cidrs  = var.control_plane_allowed_cidrs
  control_plane_is_public      = var.control_plane_is_public
  create_cluster               = var.create_cluster
  create_bastion               = var.create_bastion
  create_fss                   = var.create_fss
  create_nsgs                  = var.create_nsgs
  create_nsgs_always           = var.create_nsgs_always
  create_operator              = local.operator_enabled
  drg_attachments              = var.drg_attachments
  enable_waf                   = var.enable_waf
  ig_route_table_id            = local.ig_route_table_id
  load_balancers               = var.load_balancers
  nat_route_table_id           = local.nat_route_table_id
  subnets                      = var.subnets
  vcn_cidrs                    = local.vcn_cidrs
  vcn_id                       = local.vcn_id
  worker_is_public             = var.worker_is_public

  providers = {
    oci.home = oci.home
  }
}

# VCN
output "vcn_id" {
  description = "VCN ID"
  value       = local.vcn_id
}
output "ig_route_table_id" {
  description = "Internet gateway route table ID"
  value       = local.ig_route_table_id
}
output "nat_route_table_id" {
  description = "NAT gateway route table ID"
  value       = local.nat_route_table_id
}

# Subnets
output "subnet_ids" {
  description = "Map of subnet ids by role for the cluster and associated resources."
  value       = module.network.subnet_ids
}
output "subnet_cidrs" {
  description = "Map of provided/calculated subnet CIDR ranges by role for the cluster."
  value       = module.network.subnet_cidrs
}
output "bastion_subnet_id" {
  value = lookup(module.network.subnet_ids, "bastion", null)
}
output "operator_subnet_id" {
  value = lookup(module.network.subnet_ids, "operator", null)
}
output "control_plane_subnet_id" {
  value = lookup(module.network.subnet_ids, "cp", null)
}
output "worker_subnet_id" {
  value = lookup(module.network.subnet_ids, "workers", null)
}
output "pod_subnet_id" {
  value = lookup(module.network.subnet_ids, "pods", null)
}
output "int_lb_subnet_id" {
  value = lookup(module.network.subnet_ids, "int_lb", null)
}
output "pub_lb_subnet_id" {
  value = lookup(module.network.subnet_ids, "pub_lb", null)
}
output "fss_subnet_id" {
  value = lookup(module.network.subnet_ids, "fss", null)
}

# NSGs
output "nsg_ids" {
  description = "Map of network security group IDs by role for the cluster and associated resources."
  value = var.create_nsgs ? {
    "bastion"  = module.network.bastion_nsg_id
    "operator" = module.network.operator_nsg_id
    "cp"       = module.network.control_plane_nsg_id
    "int_lb"   = module.network.int_lb_nsg_id
    "pub_lb"   = module.network.pub_lb_nsg_id
    "workers"  = module.network.worker_nsg_id
    "pods"     = module.network.pod_nsg_id
    "fss"      = module.network.fss_nsg_id
  } : null
}

output "bastion_nsg_id" {
  description = "Network Security Group for bastion host(s)."
  value       = module.network.bastion_nsg_id
}
output "operator_nsg_id" {
  description = "Network Security Group for operator host(s)."
  value       = module.network.operator_nsg_id
}
output "control_plane_nsg_id" {
  description = "Network Security Group for Kubernetes control plane(s)."
  value       = module.network.control_plane_nsg_id
}
output "int_lb_nsg_id" {
  description = "Network Security Group for internal load balancers."
  value       = module.network.int_lb_nsg_id
}
output "pub_lb_nsg_id" {
  description = "Network Security Group for public load balancers."
  value       = module.network.pub_lb_nsg_id
}
output "worker_nsg_id" {
  description = "Network Security Group for worker nodes."
  value       = module.network.worker_nsg_id
}
output "pod_nsg_id" {
  description = "Network Security Group for pods."
  value       = module.network.pod_nsg_id
}
output "fss_nsg_id" {
  description = "Network Security Group for File Storage Service resources."
  value       = module.network.fss_nsg_id
}

output "network_security_rules" {
  value = var.output_detail ? module.network.network_security_rules : null
}

# DRG
output "drg_id" {
  description = "Dynamic routing gateway ID"
  value       = one(module.drg[*].drg_id)
}

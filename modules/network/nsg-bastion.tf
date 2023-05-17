# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  bastion_nsg_enabled = (var.vcn_id != null && var.create_nsgs && var.create_bastion) || var.create_nsgs_always
  bastion_nsg_id      = one(oci_core_network_security_group.bastion[*].id)
  bastion_rules = (var.create_nsgs && var.create_bastion) || var.create_nsgs_always ? merge(
    { for cidr in var.bastion_allowed_cidrs :
      "Allow SSH ingress to bastion from ${cidr}" => {
        protocol = local.tcp_protocol, port = local.ssh_port, source = cidr, source_type = local.rule_type_cidr,
      }
    },
    {
      "Allow SSH egress from bastion to workers" = {
        protocol = local.tcp_protocol, port = local.ssh_port, destination = local.worker_nsg_id, destination_type = local.rule_type_nsg,
        enabled  = var.allow_worker_ssh_access,
      },
    },
    (var.create_operator || var.create_nsgs_always) ? {
      "Allow SSH egress from bastion to operator" = {
        protocol = local.tcp_protocol, port = local.ssh_port, destination = local.operator_nsg_id, destination_type = local.rule_type_nsg,
      },
    } : {},
    var.allow_worker_ssh_access ? {
      "Allow SSH egress from bastion to workers" = {
        protocol = local.tcp_protocol, port = local.ssh_port, destination = local.worker_nsg_id, destination_type = local.rule_type_nsg,
      },
    } : {},
    (var.allow_bastion_cluster_access && local.control_plane_nsg_enabled) ? {
      "Allow TCP egress from bastion to cluster endpoint" = {
        protocol = local.tcp_protocol, port = local.apiserver_port, destination = local.control_plane_nsg_id, destination_type = local.rule_type_nsg,
      },
    } : {},
  ) : {}
}

resource "oci_core_network_security_group" "bastion" {
  count          = local.bastion_nsg_enabled ? 1 : 0
  compartment_id = var.compartment_id
  display_name   = "bastion-${var.state_id}"
  vcn_id         = var.vcn_id
  defined_tags   = local.defined_tags
  freeform_tags  = local.freeform_tags
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags, display_name]
  }
}

output "bastion_nsg_id" {
  value = local.bastion_nsg_id
}

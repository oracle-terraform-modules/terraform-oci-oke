# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  operator_nsg_id = one(oci_core_network_security_group.operator[*].id)
  operator_rules = var.create_operator ? merge(
    {
      "Allow TCP egress from operator to OCI services" : {
        protocol = local.tcp_protocol, port = local.all_ports, destination = local.osn, destination_type = local.rule_type_service,
      },
      "Allow TCP egress from operator to Kubernetes API server" : {
        protocol = local.tcp_protocol, port = local.apiserver_port, destination = local.cp_nsg_id, destination_type = local.rule_type_nsg,
      },
      "Allow ALL egress from operator to internet" : {
        protocol = local.all_protocols, port = local.all_ports, destination = local.anywhere, destination_type = local.rule_type_cidr,
      },
      "Allow ICMP ingress to operator for path discovery" : {
        protocol = local.icmp_protocol, port = local.all_ports, source = local.anywhere, source_type = local.rule_type_cidr,
      }
    },

    var.create_bastion ? {
      "Allow SSH ingress to operator from bastion" : {
        protocol = local.tcp_protocol, port = local.ssh_port, source = local.bastion_nsg_id, source_type = local.rule_type_nsg,
      }
    } : {},
  ) : {}
}

resource "oci_core_network_security_group" "operator" {
  count          = var.create_nsgs && var.create_operator ? 1 : 0
  compartment_id = var.compartment_id
  display_name   = "operator-${var.state_id}"
  vcn_id         = var.vcn_id
  defined_tags   = local.defined_tags
  freeform_tags  = local.freeform_tags
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

output "operator_nsg_id" {
  value = local.operator_nsg_id
}

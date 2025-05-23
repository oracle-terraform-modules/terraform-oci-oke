# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  operator_nsg_config = try(var.nsgs.operator, { create = "never" })
  operator_nsg_create = coalesce(lookup(local.operator_nsg_config, "create", null), "auto")
  operator_nsg_enabled = anytrue([
    local.operator_nsg_create == "always",
    alltrue([
      local.operator_nsg_create == "auto",
      coalesce(lookup(local.operator_nsg_config, "id", null), "none") == "none",
      var.create_cluster, var.create_operator,
    ]),
  ])
  # Return provided NSG when configured with an existing ID or created resource ID
  operator_nsg_id = one(compact([try(var.nsgs.operator.id, null), one(oci_core_network_security_group.operator[*].id)]))
  operator_rules = local.operator_nsg_enabled ? merge(
    {
      "Allow TCP egress from operator to OCI services" : {
        protocol = local.tcp_protocol, port = local.all_ports, destination = local.osn, destination_type = local.rule_type_service,
      },
      "Allow TCP egress from operator to Kubernetes API server" : {
        protocol = local.tcp_protocol, port = local.apiserver_port, destination = local.control_plane_nsg_id, destination_type = local.rule_type_nsg,
      },
      "Allow ALL egress from operator to internet" : {
        protocol = local.all_protocols, port = local.all_ports, destination = local.anywhere, destination_type = local.rule_type_cidr,
      },
    },

    local.bastion_nsg_enabled ? merge(
      var.enable_ipv6 ? {
        "Allow ICMPv6 ingress to operator from bastion for path discovery" : {
          protocol = local.icmpv6_protocol, source = local.bastion_nsg_id, source_type = local.rule_type_nsg,
        }
      } : {},
      {
        "Allow ICMP ingress to operator from bastion for path discovery" : {
          protocol = local.icmp_protocol, source = local.bastion_nsg_id, source_type = local.rule_type_nsg,
        }
        "Allow SSH ingress to operator from bastion" : {
          protocol = local.tcp_protocol, port = local.ssh_port, source = local.bastion_nsg_id, source_type = local.rule_type_nsg,
        }
    }) : {},
  ) : {}
}

resource "oci_core_network_security_group" "operator" {
  count          = local.operator_nsg_enabled ? 1 : 0
  compartment_id = var.compartment_id
  display_name   = "operator-${var.state_id}"
  vcn_id         = var.vcn_id
  defined_tags   = var.defined_tags
  freeform_tags  = var.freeform_tags
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags, display_name, vcn_id]
  }
}

output "operator_nsg_id" {
  value = local.operator_nsg_id
}

# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  int_lb_nsg_config = try(var.nsgs.int_lb, { create = "never" })
  int_lb_nsg_enabled = anytrue([
    lookup(local.int_lb_nsg_config, "create", "auto") == "always",
    alltrue([
      lookup(local.int_lb_nsg_config, "create", "auto") == "auto",
      coalesce(lookup(local.int_lb_nsg_config, "id", null), "none") == "none",
      var.create_cluster, var.load_balancers == "internal" || var.load_balancers == "both",
    ]),
  ])
  # Return provided NSG when configured with an existing ID or created resource ID
  int_lb_nsg_id = one(compact([try(var.nsgs.int_lb.id, null), one(oci_core_network_security_group.int_lb[*].id)]))
  int_lb_rules = local.int_lb_nsg_enabled ? merge(
    {
      "Allow TCP egress from internal load balancers to workers for Node Ports" : {
        protocol = local.tcp_protocol, port_min = local.node_port_min, port_max = local.node_port_max, destination = local.worker_nsg_id, destination_type = local.rule_type_nsg,
      },
      "Allow ICMP egress from internal load balancersto worker nodes for path discovery" : {
        protocol = local.icmp_protocol, port = local.all_ports, destination = local.worker_nsg_id, destination_type = local.rule_type_nsg,
      },
      "Allow TCP egress from internal load balancers to workers for health checks" : {
        protocol = local.tcp_protocol, port = local.health_check_port, destination = local.worker_nsg_id, destination_type = local.rule_type_nsg,
      },
    },
    var.enable_waf ? local.waf_rules : {},
    var.allow_rules_internal_lb,
  ) : {}
}

resource "oci_core_network_security_group" "int_lb" {
  count          = local.int_lb_nsg_enabled ? 1 : 0
  compartment_id = var.compartment_id
  display_name   = "int_lb-${var.state_id}"
  vcn_id         = var.vcn_id
  defined_tags   = var.defined_tags
  freeform_tags  = var.freeform_tags
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags, display_name]
  }
}

output "int_lb_nsg_id" {
  value = local.int_lb_nsg_id
}

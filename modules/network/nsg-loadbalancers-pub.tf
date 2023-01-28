# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  pub_lb_nsg_id = one(oci_core_network_security_group.pub_lb[*].id)
  pub_lb_rules = var.load_balancers == "public" || var.load_balancers == "both" ? merge(
    {
      "Allow TCP egress from public load balancers to workers nodes for NodePort traffic" : {
        protocol = local.tcp_protocol, port_min = local.node_port_min, port_max = local.node_port_max, destination = local.worker_nsg_id, destination_type = local.rule_type_nsg,
      },
      "Allow TCP egress from public load balancers to worker nodes for health checks" : {
        protocol = local.tcp_protocol, port = local.health_check_port, destination = local.worker_nsg_id, destination_type = local.rule_type_nsg,
      },
      "Allow ICMP egress from public load balancers to worker nodes for path discovery" : {
        protocol = local.icmp_protocol, port = local.all_ports, destination = local.worker_nsg_id, destination_type = local.rule_type_nsg,
      },
    },
    var.enable_waf ? local.waf_rules : {},
    var.allow_rules_public_lb,
  ) : {}
}

resource "oci_core_network_security_group" "pub_lb" {
  count          = var.create_nsgs && (var.load_balancers == "public" || var.load_balancers == "both") ? 1 : 0
  compartment_id = var.compartment_id
  display_name   = "pub_lb-${var.state_id}"
  vcn_id         = var.vcn_id
  defined_tags   = local.defined_tags
  freeform_tags  = local.freeform_tags
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

output "pub_lb_nsg_id" {
  value = local.pub_lb_nsg_id
}

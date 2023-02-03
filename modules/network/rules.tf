# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  waf_rules = var.enable_waf ? { # Used in load balancer NSGs if enabled
    for waf_subnet in data.oci_waas_edge_subnets.waf_cidr_blocks[0].edge_subnets : "Allow SSL ingress from WAF ${waf_subnet.cidr}" => {
      protocol = local.tcp_protocol, port = 443, source = waf_subnet.cidr, source_type = local.rule_type_cidr,
    }
  } : {}

  all_rules = { for x, y in merge(
    { for k, v in local.bastion_rules : k => merge(v, { "nsg_id" = local.bastion_nsg_id }) },
    { for k, v in local.cp_rules : k => merge(v, { "nsg_id" = local.cp_nsg_id }) },
    { for k, v in local.int_lb_rules : k => merge(v, { "nsg_id" = local.int_lb_nsg_id }) },
    { for k, v in local.pub_lb_rules : k => merge(v, { "nsg_id" = local.pub_lb_nsg_id }) },
    { for k, v in local.workers_rules : k => merge(v, { "nsg_id" = local.worker_nsg_id }) },
    { for k, v in local.pods_rules : k => merge(v, { "nsg_id" = local.pod_nsg_id }) },
    { for k, v in local.operator_rules : k => merge(v, { "nsg_id" = local.operator_nsg_id }) },
    { for k, v in local.fss_rules : k => merge(v, { "nsg_id" = local.fss_nsg_id }) },
  ) : x => y if var.create_nsgs && tobool(lookup(y, "enabled", "true")) }
}

resource "oci_core_network_security_group_security_rule" "oke" {
  for_each                  = local.all_rules
  network_security_group_id = lookup(each.value, "nsg_id")
  description               = each.key
  direction                 = contains(keys(each.value), "source") ? "INGRESS" : "EGRESS"
  protocol                  = lookup(each.value, "protocol")
  source                    = lookup(each.value, "source", null)
  source_type               = lookup(each.value, "source_type", null)
  destination               = lookup(each.value, "destination", null)
  destination_type          = lookup(each.value, "destination_type", null)
  stateless                 = false

  dynamic "tcp_options" {
    for_each = (each.value.protocol == local.tcp_protocol &&
      tonumber(lookup(each.value, "port", 0)) != local.all_ports ? [each.value] : []
    )
    content {
      destination_port_range {
        min = tonumber(lookup(tcp_options.value, "port_min", lookup(tcp_options.value, "port", 0)))
        max = tonumber(lookup(tcp_options.value, "port_max", lookup(tcp_options.value, "port", 0)))
      }
    }
  }

  dynamic "udp_options" {
    for_each = (each.value.protocol == local.udp_protocol &&
      tonumber(lookup(each.value, "port", 0)) != local.all_ports ? [each.value] : []
    )
    content {
      destination_port_range {
        min = tonumber(lookup(udp_options.value, "port_min", lookup(udp_options.value, "port", 0)))
        max = tonumber(lookup(udp_options.value, "port_max", lookup(udp_options.value, "port", 0)))
      }
    }
  }

  dynamic "icmp_options" {
    for_each = each.value.protocol == local.icmp_protocol ? [1] : []
    content {
      type = 3
      code = 4
    }
  }

  lifecycle {
    precondition {
      condition = each.value.protocol == local.icmp_protocol || contains(keys(each.value), "port") || (
        contains(keys(each.value), "port_min") && contains(keys(each.value), "port_max")
      )
      error_message = "TCP/UDP rule must contain a port or port range: '${each.key}'"
    }

    precondition {
      condition = (
        each.value.protocol == local.icmp_protocol
        || can(tonumber(each.value.port))
        || (can(tonumber(each.value.port_min)) && can(tonumber(each.value.port_max)))
      )

      error_message = "TCP/UDP ports must be numeric: '${each.key}'"
    }
  }
}

output "network_security_rules" {
  value = local.all_rules
}

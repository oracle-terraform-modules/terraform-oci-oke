# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  waf_rules = var.enable_waf ? { # Used in load balancer NSGs if enabled
    for waf_subnet in data.oci_waas_edge_subnets.waf_cidr_blocks[0].edge_subnets : "Allow SSL ingress from WAF ${waf_subnet.cidr}" => {
      protocol = local.tcp_protocol, port = 443, source = waf_subnet.cidr, source_type = local.rule_type_cidr,
    }
  } : {}

  # Dynamic map of all NSG rules for enabled NSGs
  all_rules = { for x, y in merge(
    { for k, v in local.bastion_rules : k => merge(v, { "nsg_id" = local.bastion_nsg_id }) },
    { for k, v in local.control_plane_rules : k => merge(v, { "nsg_id" = local.control_plane_nsg_id }) },
    { for k, v in local.int_lb_rules : k => merge(v, { "nsg_id" = local.int_lb_nsg_id }) },
    { for k, v in local.pub_lb_rules : k => merge(v, { "nsg_id" = local.pub_lb_nsg_id }) },
    { for k, v in local.workers_rules : k => merge(v, { "nsg_id" = local.worker_nsg_id }) },
    { for k, v in local.pods_rules : k => merge(v, { "nsg_id" = local.pod_nsg_id }) },
    { for k, v in local.operator_rules : k => merge(v, { "nsg_id" = local.operator_nsg_id }) },
    { for k, v in local.fss_rules : k => merge(v, { "nsg_id" = local.fss_nsg_id }) },
    ) : x => merge(y, {
      description               = x
      network_security_group_id = lookup(y, "nsg_id")
      direction                 = contains(keys(y), "source") ? "INGRESS" : "EGRESS"
      protocol                  = lookup(y, "protocol")
      source                    = lookup(y, "source", null)
      source_type               = lookup(y, "source_type", null)
      destination               = lookup(y, "destination", null)
      destination_type          = lookup(y, "destination_type", null)
  }) }

  # Dynamic map of all NSG IDs for enabled NSGs
  all_nsg_ids = { for x, y in merge(
    local.bastion_nsg_enabled ? { "bastion" = local.bastion_nsg_id } : {},
    local.control_plane_nsg_enabled ? { "cp" = local.control_plane_nsg_id } : {},
    local.int_lb_nsg_enabled ? { "int_lb" = local.int_lb_nsg_id } : {},
    local.pub_lb_nsg_enabled ? { "pub_lb" = local.pub_lb_nsg_id } : {},
    local.worker_nsg_enabled ? { "workers" = local.worker_nsg_id } : {},
    local.pod_nsg_enabled ? { "pods" = local.pod_nsg_id } : {},
    local.operator_nsg_enabled ? { "operator" = local.operator_nsg_id } : {},
    local.fss_nsg_enabled ? { "fss" = local.fss_nsg_id } : {},
  ) : x => y }
}

resource "oci_core_network_security_group_security_rule" "oke" {
  for_each                  = local.all_rules
  stateless                 = false
  description               = each.value.description
  destination               = each.value.destination
  destination_type          = each.value.destination_type
  direction                 = each.value.direction
  network_security_group_id = each.value.network_security_group_id
  protocol                  = each.value.protocol
  source                    = each.value.source
  source_type               = each.value.source_type

  dynamic "tcp_options" {
    for_each = (tostring(each.value.protocol) == tostring(local.tcp_protocol) &&
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
    for_each = (tostring(each.value.protocol) == tostring(local.udp_protocol) &&
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
    for_each = tostring(each.value.protocol) == tostring(local.icmp_protocol) ? [1] : []
    content {
      type = 3
      code = 4
    }
  }

  lifecycle {
    precondition {
      condition = tostring(each.value.protocol) == tostring(local.icmp_protocol) || contains(keys(each.value), "port") || (
        contains(keys(each.value), "port_min") && contains(keys(each.value), "port_max")
      )
      error_message = "TCP/UDP rule must contain a port or port range: '${each.key}'"
    }

    precondition {
      condition = (
        tostring(each.value.protocol) == tostring(local.icmp_protocol)
        || can(tonumber(each.value.port))
        || (can(tonumber(each.value.port_min)) && can(tonumber(each.value.port_max)))
      )

      error_message = "TCP/UDP ports must be numeric: '${each.key}'"
    }

    precondition {
      condition     = each.value.direction == "EGRESS" || coalesce(each.value.source, "none") != "none"
      error_message = "Ingress rule must have a source: '${each.key}'"
    }

    precondition {
      condition     = each.value.direction == "INGRESS" || coalesce(each.value.destination, "none") != "none"
      error_message = "Egress rule must have a destination: '${each.key}'"
    }

    # Extra precaution against unexpected allow-all ingress rules created by the module
    # Generated rules will produce errors unless any of the follow conditions are true
    precondition {
      condition = anytrue([
        tostring(each.value.protocol) == tostring(local.icmp_protocol), # Traffic is ICMP
        each.value.direction == "EGRESS",                               # Traffic is outbound
        each.value.source != local.anywhere,                            # Rule does not allow all traffic

        # SSH ingress to bastion from anywhere has been configured explicitly
        alltrue([
          tonumber(lookup(each.value, "port", 0)) == local.ssh_port,
          contains(var.bastion_allowed_cidrs, local.anywhere),
        ]),

        # TCP ingress to Kubernetes endpoint from anywhere has been configured explicitly
        alltrue([
          tonumber(lookup(each.value, "port", 0)) == local.apiserver_port,
          contains(var.control_plane_allowed_cidrs, local.anywhere),
        ]),
      ])
      error_message = "Unexpected open ingress rule: ${each.key}"
    }
  }
}

output "network_security_rules" {
  value = local.all_rules
}

output "nsg_ids" {
  value = length(local.all_nsg_ids) > 0 ? local.all_nsg_ids : null
}

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
      stateless                 = lookup(y, "stateless", false)
      network_security_group_id = lookup(y, "nsg_id")
      direction                 = contains(keys(y), "source") ? "INGRESS" : "EGRESS"
      protocol                  = lookup(y, "protocol")
      source = (
        alltrue([
          upper(lookup(y, "source_type", "")) == local.rule_type_nsg,
        length(regexall("ocid\\d+\\.networksecuritygroup", lower(lookup(y, "source", "")))) == 0]) ?
        lookup(local.all_nsg_ids, lower(lookup(y, "source", "")), null) :
        lookup(y, "source", null)
      )
      source_type = lookup(y, "source_type", null)
      destination = (
        alltrue([
          upper(lookup(y, "destination_type", "")) == local.rule_type_nsg,
        length(regexall("ocid\\d+\\.networksecuritygroup", lower(lookup(y, "destination", "")))) == 0]) ?
        lookup(local.all_nsg_ids, lower(lookup(y, "destination", "")), null) :
        lookup(y, "destination", null)
      )
      destination_type = lookup(y, "destination_type", null)
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
  stateless                 = each.value.stateless
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
      dynamic "destination_port_range" {
        for_each = (
          (contains(keys(tcp_options.value), "destination_port_min") &&
          contains(keys(tcp_options.value), "destination_port_max")) ||
          (contains(keys(tcp_options.value), "source_port_min") &&
          contains(keys(tcp_options.value), "source_port_max"))
        ) ? [] : [tcp_options.value]
        content {
          min = tonumber(lookup(destination_port_range.value, "port_min", lookup(destination_port_range.value, "port", 0)))
          max = tonumber(lookup(destination_port_range.value, "port_max", lookup(destination_port_range.value, "port", 0)))
        }
      }
      dynamic "destination_port_range" {
        for_each = (contains(keys(tcp_options.value), "destination_port_min") &&
        contains(keys(tcp_options.value), "destination_port_max")) ? [tcp_options.value] : []
        content {
          min = tonumber(lookup(destination_port_range.value, "destination_port_min", 0))
          max = tonumber(lookup(destination_port_range.value, "destination_port_max", 0))
        }
      }
      dynamic "source_port_range" {
        for_each = (contains(keys(tcp_options.value), "source_port_min") &&
        contains(keys(tcp_options.value), "source_port_max")) ? [tcp_options.value] : []
        content {
          min = tonumber(lookup(source_port_range.value, "source_port_min", 0))
          max = tonumber(lookup(source_port_range.value, "source_port_max", 0))
        }
      }
    }
  }

  dynamic "udp_options" {
    for_each = (tostring(each.value.protocol) == tostring(local.udp_protocol) &&
      tonumber(lookup(each.value, "port", 0)) != local.all_ports ? [each.value] : []
    )
    content {
      dynamic "destination_port_range" {
        for_each = (
          (contains(keys(udp_options.value), "destination_port_min") &&
          contains(keys(udp_options.value), "destination_port_max")) ||
          (contains(keys(udp_options.value), "source_port_min") &&
          contains(keys(udp_options.value), "source_port_max"))
        ) ? [] : [udp_options.value]
        content {
          min = tonumber(lookup(destination_port_range.value, "port_min", lookup(destination_port_range.value, "port", 0)))
          max = tonumber(lookup(destination_port_range.value, "port_max", lookup(destination_port_range.value, "port", 0)))
        }
      }
      dynamic "destination_port_range" {
        for_each = (contains(keys(udp_options.value), "destination_port_min") &&
        contains(keys(udp_options.value), "destination_port_max")) ? [udp_options.value] : []
        content {
          min = tonumber(lookup(destination_port_range.value, "destination_port_min", 0))
          max = tonumber(lookup(destination_port_range.value, "destination_port_max", 0))
        }
      }
      dynamic "source_port_range" {
        for_each = (contains(keys(udp_options.value), "source_port_min") &&
        contains(keys(udp_options.value), "source_port_max")) ? [udp_options.value] : []
        content {
          min = tonumber(lookup(source_port_range.value, "source_port_min", 0))
          max = tonumber(lookup(source_port_range.value, "source_port_max", 0))
        }
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

  dynamic "icmp_options" {
    for_each = tostring(each.value.protocol) == tostring(local.icmpv6_protocol) ? [1] : []
    content {
      type = 2
      code = 0
    }
  }

  lifecycle {
    precondition {
      condition = contains([tostring(local.icmp_protocol), tostring(local.icmpv6_protocol)], tostring(each.value.protocol)) || contains(keys(each.value), "port") || (
        contains(keys(each.value), "port_min") && contains(keys(each.value), "port_max")) || (
        contains(keys(each.value), "source_port_min") && contains(keys(each.value), "source_port_max") || (
          contains(keys(each.value), "destination_port_min") && contains(keys(each.value), "destination_port_max")
        )
      )
      error_message = "TCP/UDP rule must contain a port or port range: '${each.key}'"
    }

    precondition {
      condition = (
        contains([tostring(local.icmp_protocol), tostring(local.icmpv6_protocol)], tostring(each.value.protocol))
        || can(tonumber(each.value.port))
        || (can(tonumber(each.value.port_min)) && can(tonumber(each.value.port_max)))
        || (can(tonumber(each.value.source_port_min)) && can(tonumber(each.value.source_port_max)))
        || (can(tonumber(each.value.destination_port_min)) && can(tonumber(each.value.destination_port_max)))
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

        # TCP ingress to internal load balancer from anywhere has been configured explicitly
        contains(keys(var.allow_rules_internal_lb), each.key),

        # TCP ingress to public load balancer from anywhere has been configured explicitly
        contains(keys(var.allow_rules_public_lb), each.key),

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

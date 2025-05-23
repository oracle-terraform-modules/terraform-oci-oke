# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  pod_nsg_config = try(var.nsgs.pods, { create = "never" })
  pod_nsg_create = coalesce(lookup(local.pod_nsg_config, "create", null), "auto")
  pod_nsg_enabled = anytrue([
    local.pod_nsg_create == "always",
    alltrue([
      local.pod_nsg_create == "auto",
      coalesce(lookup(local.pod_nsg_config, "id", null), "none") == "none",
      var.create_cluster, var.cni_type == "npn",
    ]),
  ])
  # Return provided NSG when configured with an existing ID or created resource ID
  pod_nsg_id = one(compact([try(var.nsgs.pods.id, null), one(oci_core_network_security_group.pods[*].id)]))
  pods_rules = local.pod_nsg_enabled ? merge(
    {
      "Allow TCP egress from pods to OCI Services" : {
        protocol = local.tcp_protocol, port = local.all_ports, destination = local.osn, destination_type = local.rule_type_service,
      },

      "Allow ALL egress from pods to other pods" = {
        protocol = local.all_protocols, port = local.all_ports, destination = local.pod_nsg_id, destination_type = local.rule_type_nsg,
      }
      "Allow ALL ingress to pods from other pods" = {
        protocol = local.all_protocols, port = local.all_ports, source = local.pod_nsg_id, source_type = local.rule_type_nsg,
      }

      "Allow TCP egress from pods to Kubernetes API server" = {
        protocol = local.tcp_protocol, port = local.apiserver_port, destination = local.control_plane_nsg_id, destination_type = local.rule_type_nsg,
      }
      "Allow ALL ingress to pods from Kubernetes control plane for webhooks served by pods" = {
        protocol = local.all_protocols, port = local.all_ports, source = local.control_plane_nsg_id, source_type = local.rule_type_nsg,
      }

      "Allow ALL egress from pods for cross-node pod communication when using NodePorts or hostNetwork: true" = {
        protocol = local.all_protocols, port = local.all_ports, destination = local.worker_nsg_id, destination_type = local.rule_type_nsg,
      }
      "Allow ALL ingress to pods for cross-node pod communication when using NodePorts or hostNetwork: true" = {
        protocol = local.all_protocols, port = local.all_ports, source = local.worker_nsg_id, source_type = local.rule_type_nsg,
      }

      "Allow ICMP egress from pods for path discovery" = {
        protocol = local.icmp_protocol, port = local.all_ports, destination = local.anywhere, destination_type = local.rule_type_cidr,
      }
      "Allow ICMP ingress to pods for path discovery" = {
        protocol = local.icmp_protocol, port = local.all_ports, source = local.anywhere, source_type = local.rule_type_cidr,
      }
    },

    var.enable_ipv6 ? {
      "Allow ICMPv6 ingress to pods for path discovery" : {
        protocol = local.icmpv6_protocol, port = local.all_ports, source = local.anywhere_ipv6, source_type = local.rule_type_cidr,
      },
      "Allow ICMPv6 egress from pods for path discovery" : {
        protocol = local.icmpv6_protocol, port = local.all_ports, destination = local.anywhere_ipv6, destination_type = local.rule_type_cidr,
      },
    } : {},

    var.allow_pod_internet_access ?
    merge(
      var.enable_ipv6 ? {
        "Allow ALL IPv6 egress from pods to internet" = {
          protocol = local.all_protocols, port = local.all_ports, destination = local.anywhere_ipv6, destination_type = local.rule_type_cidr,
        }
      } : {},
      {
        "Allow ALL egress from pods to internet" = {
          protocol = local.all_protocols, port = local.all_ports, destination = local.anywhere, destination_type = local.rule_type_cidr,
        }
    }) : {},
    var.allow_rules_pods
  ) : {}
}

resource "oci_core_network_security_group" "pods" {
  count          = local.pod_nsg_enabled ? 1 : 0
  compartment_id = var.compartment_id
  display_name   = "pods-${var.state_id}"
  vcn_id         = var.vcn_id
  defined_tags   = var.defined_tags
  freeform_tags  = var.freeform_tags
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags, display_name, vcn_id]
  }
}

output "pod_nsg_id" {
  value = local.pod_nsg_id
}

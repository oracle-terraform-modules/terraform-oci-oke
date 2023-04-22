# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  pod_nsg_enabled = (var.cni_type == "npn" && var.create_nsgs && var.create_cluster) || var.create_nsgs_always
  pod_nsg_id      = one(oci_core_network_security_group.pods[*].id)
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
    var.allow_pod_internet_access ? {
      "Allow ALL egress from pods to internet" = {
        protocol = local.all_protocols, port = local.all_ports, destination = local.anywhere, destination_type = local.rule_type_cidr,
      }
    } : {},
  ) : {}
}

resource "oci_core_network_security_group" "pods" {
  count          = local.pod_nsg_enabled ? 1 : 0
  compartment_id = var.compartment_id
  display_name   = "pods-${var.state_id}"
  vcn_id         = var.vcn_id
  defined_tags   = local.defined_tags
  freeform_tags  = local.freeform_tags
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags, display_name]
  }
}

output "pod_nsg_id" {
  value = local.pod_nsg_id
}

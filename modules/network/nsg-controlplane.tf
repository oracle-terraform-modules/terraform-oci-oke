# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  cp_nsg_id = one(oci_core_network_security_group.cp[*].id)
  cp_rules = merge(
    {
      "Allow TCP egress from OKE control plane to OCI services" : {
        protocol = local.tcp_protocol, port = local.all_ports, destination = local.osn, destination_type = local.rule_type_service,
      },
      "Allow TCP egress from OKE control plane to Kubelet on worker nodes" : {
        protocol = local.tcp_protocol, port = local.kubelet_api_port, destination = local.worker_nsg_id, destination_type = local.rule_type_nsg,
      },

      "Allow TCP ingress to OKE control plane from worker nodes" : {
        protocol = local.tcp_protocol, port = local.oke_port, source = local.worker_nsg_id, source_type = local.rule_type_nsg,
      },
      "Allow TCP egress from OKE control plane to worker nodes" : {
        protocol = local.tcp_protocol, port = local.oke_port, destination = local.worker_nsg_id, destination_type = local.rule_type_nsg,
      },

      "Allow TCP egress for Kubernetes control plane inter-communication" : {
        protocol = local.tcp_protocol, port = local.apiserver_port, destination = local.cp_nsg_id, destination_type = local.rule_type_nsg,
      },
      "Allow TCP ingress for Kubernetes control plane inter-communication" : {
        protocol = local.tcp_protocol, port = local.apiserver_port, source = local.cp_nsg_id, source_type = local.rule_type_nsg,
      },
      "Allow TCP ingress to kube-apiserver from worker nodes" : {
        protocol = local.tcp_protocol, port = local.apiserver_port, source = local.worker_nsg_id, source_type = local.rule_type_nsg,
      },
      "Allow TCP ingress to kube-apiserver from operator instance" : {
        protocol = local.tcp_protocol, port = local.apiserver_port, source = local.operator_nsg_id, source_type = local.rule_type_nsg,
        enabled  = var.create_operator,
      },

      "Allow ICMP egress for path discovery to worker nodes" : {
        protocol = local.icmp_protocol, destination = local.worker_nsg_id, destination_type = local.rule_type_nsg,
      },
      "Allow ICMP ingress for path discovery from worker nodes" : {
        protocol = local.icmp_protocol, source = local.worker_nsg_id, source_type = local.rule_type_nsg,
      },
    },

    var.cni_type == "npn" ? {
      "Allow TCP ingress to kube-apiserver from pods" : {
        protocol = local.tcp_protocol, port = local.apiserver_port, source = local.pod_nsg_id, source_type = local.rule_type_nsg,
      },
      "Allow TCP ingress to OKE control plane from pods" : {
        protocol = local.tcp_protocol, port = local.oke_port, source = local.pod_nsg_id, source_type = local.rule_type_nsg,
      },
      "Allow TCP egress from OKE control plane to pods" : {
        protocol = local.tcp_protocol, port = local.all_ports, destination = local.pod_nsg_id, destination_type = local.rule_type_nsg,
      },
      "Allow TCP ingress from pods to kube-apiserver" : {
        protocol = local.tcp_protocol, port = local.oke_port, source = local.pod_nsg_id, source_type = local.rule_type_nsg,
      },
    } : {},

    { for allowed_cidr in var.control_plane_allowed_cidrs :
      "Allow TCP ingress to kube-apiserver from ${allowed_cidr}" => {
        protocol = local.tcp_protocol, port = local.apiserver_port, source = allowed_cidr, source_type = local.rule_type_cidr
      }
    },
  )
}

resource "oci_core_network_security_group" "cp" {
  count          = var.create_nsgs ? 1 : 0
  compartment_id = var.compartment_id
  display_name   = "cp-${var.state_id}"
  vcn_id         = var.vcn_id
  defined_tags   = local.defined_tags
  freeform_tags  = local.freeform_tags
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

output "cp_nsg_id" {
  value = local.cp_nsg_id
}

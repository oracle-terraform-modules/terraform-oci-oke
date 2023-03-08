# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  fss_nsg_enabled = (var.create_nsgs && var.create_fss) || var.create_nsgs_always
  fss_nsg_id      = one(oci_core_network_security_group.fss[*].id)
  fss_rules = local.fss_nsg_enabled ? {
    # See https://docs.oracle.com/en-us/iaas/Content/File/Tasks/securitylistsfilestorage.htm
    # Ingress
    "Allow UDP ingress for NFS portmapper from workers" : {
      protocol = local.udp_protocol, port = local.fss_nfs_portmapper_port, source = local.worker_nsg_id, source_type = local.rule_type_nsg,
    },
    "Allow TCP ingress for NFS portmapper from workers" : {
      protocol = local.tcp_protocol, port = local.fss_nfs_portmapper_port, source = local.worker_nsg_id, source_type = local.rule_type_nsg,
    },
    "Allow UDP ingress for NFS from workers" : {
      protocol = local.udp_protocol, port = local.fss_nfs_port_min, source = local.worker_nsg_id, source_type = local.rule_type_nsg,
    },
    "Allow TCP ingress for NFS from workers" : {
      protocol = local.tcp_protocol, port_min = local.node_port_min, port_max = local.node_port_max, source = local.worker_nsg_id, source_type = local.rule_type_nsg,
    },

    # Egress
    "Allow UDP egress for NFS portmapper to workers" : {
      protocol = local.udp_protocol, port = local.fss_nfs_portmapper_port, destination = local.worker_nsg_id, destination_type = local.rule_type_nsg,
    },
    "Allow TCP egress for NFS portmapper to workers" : {
      protocol = local.tcp_protocol, port = local.fss_nfs_portmapper_port, destination = local.worker_nsg_id, destination_type = local.rule_type_nsg,
    },
    "Allow TCP egress for NFS to workers" : {
      protocol = local.tcp_protocol, port_min = local.node_port_min, port_max = local.node_port_max, destination = local.worker_nsg_id, destination_type = local.rule_type_nsg,
    },
  } : {}
}

resource "oci_core_network_security_group" "fss" {
  count          = local.fss_nsg_enabled ? 1 : 0
  compartment_id = var.compartment_id
  display_name   = "fss-${var.state_id}"
  vcn_id         = var.vcn_id
  defined_tags   = local.defined_tags
  freeform_tags  = local.freeform_tags
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

output "fss_nsg_id" {
  value = local.fss_nsg_id
}

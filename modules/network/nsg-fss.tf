# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  fss_nsg_config = try(var.nsgs.fss, { create = "never" })
  fss_nsg_create = coalesce(lookup(local.fss_nsg_config, "create", null), "auto")
  fss_nsg_enabled = anytrue([
    local.fss_nsg_create == "always",
    alltrue([
      local.fss_nsg_create == "auto",
      coalesce(lookup(local.fss_nsg_config, "id", null), "none") == "none",
      var.create_cluster,
    ]),
  ])
  # Return provided NSG when configured with an existing ID or created resource ID
  fss_nsg_id = one(compact([try(var.nsgs.fss.id, null), one(oci_core_network_security_group.fss[*].id)]))
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
      protocol = local.tcp_protocol, port_min = local.fss_nfs_port_min, port_max = local.fss_nfs_port_max, source = local.worker_nsg_id, source_type = local.rule_type_nsg,
    },

    # Egress
    "Allow UDP egress for NFS portmapper to the workers" : {
      protocol = local.udp_protocol, source_port_min = local.fss_nfs_portmapper_port, source_port_max = local.fss_nfs_portmapper_port, destination = local.worker_nsg_id, destination_type = local.rule_type_nsg,
    },
    "Allow TCP egress for NFS portmapper to the workers" : {
      protocol = local.tcp_protocol, source_port_min = local.fss_nfs_portmapper_port, source_port_max = local.fss_nfs_portmapper_port, destination = local.worker_nsg_id, destination_type = local.rule_type_nsg,
    },
    "Allow TCP egress for NFS to the workers" : {
      protocol = local.tcp_protocol, source_port_min = local.fss_nfs_port_min, source_port_max = local.fss_nfs_port_max, destination = local.worker_nsg_id, destination_type = local.rule_type_nsg,
    },
  } : {}
}

resource "oci_core_network_security_group" "fss" {
  count          = local.fss_nsg_enabled ? 1 : 0
  compartment_id = var.compartment_id
  display_name   = "fss-${var.state_id}"
  vcn_id         = var.vcn_id
  defined_tags   = var.defined_tags
  freeform_tags  = var.freeform_tags
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags, display_name, vcn_id]
  }
}

output "fss_nsg_id" {
  value = local.fss_nsg_id
}

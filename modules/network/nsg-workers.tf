# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  worker_nsg_enabled = (var.create_nsgs && var.create_cluster) || var.create_nsgs_always
  worker_nsg_id      = one(oci_core_network_security_group.workers[*].id)
  workers_rules = local.worker_nsg_enabled ? merge(
    {
      "Allow TCP egress from workers to OCI Services" : {
        protocol = local.tcp_protocol, port = local.all_ports, destination = local.osn, destination_type = local.rule_type_service,
      },

      "Allow ALL egress from workers to other workers" : {
        protocol = local.all_protocols, port = local.all_ports, destination = local.worker_nsg_id, destination_type = local.rule_type_nsg,
      },
      "Allow ALL ingress to workers from other workers" : {
        protocol = local.all_protocols, port = local.all_ports, source = local.worker_nsg_id, source_type = local.rule_type_nsg,
      },

      "Allow TCP egress from workers to Kubernetes API server" : {
        protocol = local.tcp_protocol, port = local.apiserver_port, destination = local.control_plane_nsg_id, destination_type = local.rule_type_nsg,
      },
      "Allow TCP egress from workers to OKE control plane" : {
        protocol = local.tcp_protocol, port = local.oke_port, destination = local.control_plane_nsg_id, destination_type = local.rule_type_nsg,
      },
      "Allow TCP ingress to workers for health check from OKE control plane" : {
        protocol = local.tcp_protocol, port = local.kubelet_api_port, destination = local.control_plane_nsg_id, destination_type = local.rule_type_nsg,
      },
      "Allow ALL ingress to workers from Kubernetes control plane for webhooks served by workers" : {
        protocol = local.all_protocols, port = local.all_ports, source = local.control_plane_nsg_id, source_type = local.rule_type_nsg,
      },
      "Allow ICMP egress from workers for path discovery" : {
        protocol = local.icmp_protocol, port = local.all_ports, destination = local.anywhere, destination_type = local.rule_type_cidr,
      },
      "Allow ICMP ingress to workers for path discovery" : {
        protocol = local.icmp_protocol, port = local.all_ports, source = local.anywhere, source_type = local.rule_type_cidr,
      },
    },

    var.cni_type == "npn" ? {
      "Allow ALL egress from workers to pods" : {
        protocol = local.all_protocols, port = local.all_ports, destination = local.pod_nsg_id, destination_type = local.rule_type_nsg,
      },
      "Allow ALL ingress to workers from pods" : {
        protocol = local.all_protocols, port = local.all_ports, source = local.pod_nsg_id, source_type = local.rule_type_nsg,
      },
    } : {},

    var.allow_worker_internet_access ? {
      "Allow ALL egress from workers to internet" : {
        protocol = local.all_protocols, port = local.all_ports, destination = local.anywhere, destination_type = local.rule_type_cidr,
      },
    } : {},

    var.allow_node_port_access && (var.load_balancers == "internal" || var.load_balancers == "both") ? {
      "Allow TCP ingress to workers from internal load balancers" : {
        protocol = local.tcp_protocol, port_min = local.node_port_min, port_max = local.node_port_max, source = local.int_lb_nsg_id, source_type = local.rule_type_nsg,
      },
      "Allow TCP ingress to workers for health check from internal load balancers" : {
        protocol = local.tcp_protocol, port = local.health_check_port, source = local.int_lb_nsg_id, source_type = local.rule_type_nsg,
      },
    } : {},

    var.allow_node_port_access && (var.load_balancers == "public" || var.load_balancers == "both") ? {
      "Allow TCP ingress to workers from public load balancers" : {
        protocol = local.tcp_protocol, port_min = local.node_port_min, port_max = local.node_port_max, source = local.pub_lb_nsg_id, source_type = local.rule_type_nsg,
      },
      "Allow TCP ingress to workers for health check from public load balancers" : {
        protocol = local.tcp_protocol, port = local.health_check_port, source = local.pub_lb_nsg_id, source_type = local.rule_type_nsg,
      },
    } : {},

    (var.create_bastion || var.create_nsgs_always) && var.allow_worker_ssh_access ? {
      "Allow SSH ingress to workers from bastion" : {
        protocol = local.tcp_protocol, port = local.ssh_port, source = local.bastion_nsg_id, source_type = local.rule_type_nsg,
      }
    } : {},

    (var.create_fss || var.create_nsgs_always) ? {
      # See https://docs.oracle.com/en-us/iaas/Content/File/Tasks/securitylistsfilestorage.htm
      # Ingress
      "Allow TCP ingress to workers for NFS portmapper from FSS mounts" : {
        protocol = local.tcp_protocol, port = local.fss_nfs_portmapper_port, source = local.fss_nsg_id, source_type = local.rule_type_nsg,
      },
      "Allow UDP ingress to workers for NFS portmapper from FSS mounts" : {
        protocol = local.udp_protocol, port = local.fss_nfs_portmapper_port, source = local.fss_nsg_id, source_type = local.rule_type_nsg,
      },
      "Allow TCP ingress to workers for NFS from FSS mounts" : {
        protocol = local.tcp_protocol, port_min = local.fss_nfs_port_min, port_max = local.fss_nfs_port_max, source = local.fss_nsg_id, source_type = local.rule_type_nsg,
      },

      # Egress
      "Allow TCP egress from workers for NFS portmapper to FSS mounts" : {
        protocol = local.tcp_protocol, port = local.fss_nfs_portmapper_port, destination = local.fss_nsg_id, destination_type = local.rule_type_nsg,
      },
      "Allow UDP egress from workers for NFS portmapper to FSS mounts" : {
        protocol = local.udp_protocol, port = local.fss_nfs_portmapper_port, destination = local.fss_nsg_id, destination_type = local.rule_type_nsg,
      },
      "Allow TCP egress from workers for NFS to FSS mounts" : {
        protocol = local.tcp_protocol, port_min = local.fss_nfs_port_min, port_max = local.fss_nfs_port_max, destination = local.fss_nsg_id, destination_type = local.rule_type_nsg,
      },
      "Allow UDP egress from workers for NFS to FSS mounts" : {
        protocol = local.udp_protocol, port = local.fss_nfs_port_min, destination = local.fss_nsg_id, destination_type = local.rule_type_nsg,
      },
  } : {}) : {}
}

resource "oci_core_network_security_group" "workers" {
  count          = local.worker_nsg_enabled ? 1 : 0
  compartment_id = var.compartment_id
  display_name   = "workers-${var.state_id}"
  vcn_id         = var.vcn_id
  defined_tags   = local.defined_tags
  freeform_tags  = local.freeform_tags
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags, display_name]
  }
}

output "worker_nsg_id" {
  value = local.worker_nsg_id
}

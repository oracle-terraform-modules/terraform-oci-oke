# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {

  # subnet cidrs - used by subnets
  bastion_subnet = cidrsubnet(var.oke_network_vcn.vcn_cidr, var.oke_network_vcn.newbits["bastion"], var.oke_network_vcn.netnum["bastion"])
  cp_subnet      = cidrsubnet(var.oke_network_vcn.vcn_cidr, var.oke_network_vcn.newbits["cp"], var.oke_network_vcn.netnum["cp"])
  int_lb_subnet  = cidrsubnet(var.oke_network_vcn.vcn_cidr, var.oke_network_vcn.newbits["lb"], var.oke_network_vcn.netnum["int_lb"])
  pub_lb_subnet  = cidrsubnet(var.oke_network_vcn.vcn_cidr, var.oke_network_vcn.newbits["lb"], var.oke_network_vcn.netnum["pub_lb"])
  worker_subnet  = cidrsubnet(var.oke_network_vcn.vcn_cidr, var.oke_network_vcn.newbits["workers"], var.oke_network_vcn.netnum["workers"])

  anywhere = "0.0.0.0/0"

  # port numbers
  node_port_min = 30000

  node_port_max = 32767

  ssh_port = 22

  # protocols
  # # special OCI designation for all protocols
  all_protocols = "all"

  # # IANA protocol numbers
  icmp_protocol = 1

  tcp_protocol = 6

  udp_protocol = 17

  # oracle services network
  osn = lookup(data.oci_core_services.all_oci_services.services[0], "cidr_block")

  # if port = -1, allow all ports

  # control plane
  cp_egress = [
    {
      description      = "Allow Kubernetes control plane to communicate with OKE",
      destination      = local.osn,
      destination_type = "SERVICE_CIDR_BLOCK",
      protocol         = local.tcp_protocol,
      port             = 443,
      stateless        = false
    },
    {
      description      = "Allow all traffic to worker nodes",
      destination      = local.worker_subnet,
      destination_type = "CIDR_BLOCK",
      protocol         = local.tcp_protocol,
      port             = -1,
      stateless        = false
    },
    {
      description      = "Allow path discovery to worker nodes",
      destination      = local.worker_subnet,
      destination_type = "CIDR_BLOCK",
      protocol         = local.icmp_protocol,
      port             = -1,
      stateless        = false
    },
  ]

  cp_ingress = [
    {
      description = "Allow worker nodes to control plane API endpoint communication"
      protocol    = local.tcp_protocol,
      port        = 6443,
      source      = local.worker_subnet,
      stateless   = false
    },
    {
      description = "Allow worker nodes to control plane communication"
      protocol    = local.tcp_protocol,
      port        = 12250,
      source      = local.worker_subnet,
      stateless   = false
    },
    {
      description = "Allow path discovery from worker nodes"
      protocol    = local.icmp_protocol,
      port        = -1,
      source      = local.worker_subnet,
      stateless   = false
    },
    {
      description = "Allow external access to control plane API endpoint communication"
      protocol    = local.tcp_protocol,
      port        = 6443,
      source      = var.cluster_access_source,
      stateless   = false
    },
  ]

  # workers
  workers_egress = [
    {
      description      = "Allow egress for all traffic to allow pods to communicate between each other on different worker nodes on the worker subnet",
      destination      = local.worker_subnet,
      destination_type = "CIDR_BLOCK",
      protocol         = tostring(local.all_protocols),
      port             = -1,
      stateless        = false
    },
    {
      description      = "Allow path discovery",
      destination      = local.anywhere,
      destination_type = "CIDR_BLOCK",
      protocol         = tostring(local.icmp_protocol),
      port             = -1,
      stateless        = false
    },
    {
      description      = "Allow worker nodes to communicate with OKE",
      destination      = local.osn,
      destination_type = "SERVICE_CIDR_BLOCK",
      protocol         = tostring(local.tcp_protocol),
      port             = -1,
      stateless        = false
    },
    {
      description      = "Allow worker nodes to control plane API endpoint communication",
      destination      = local.cp_subnet,
      destination_type = "CIDR_BLOCK",
      protocol         = tostring(local.tcp_protocol),
      port             = 6443,
      stateless        = false
    },
    {
      description      = "Allow worker nodes to control plane communication",
      destination      = local.cp_subnet,
      destination_type = "CIDR_BLOCK",
      protocol         = tostring(local.tcp_protocol),
      port             = 12250,
      stateless        = false
    },
    {
      description      = "Allow worker nodes access to Internet. Required for getting container images or using external services",
      destination      = local.anywhere,
      destination_type = "CIDR_BLOCK",
      protocol         = tostring(local.tcp_protocol),
      port             = -1,
      stateless        = false
    }    
  ]

  workers_ingress = [
    {
      description = "Allow ingress for all traffic to allow pods to communicate between each other on different worker nodes on the worker subnet",
      protocol    = local.all_protocols,
      port        = -1,
      source      = local.worker_subnet,
      stateless   = false
    },
    {
      description = "Allow control plane to communicate with worker nodes",
      protocol    = local.tcp_protocol,
      port        = -1,
      source      = local.cp_subnet,
      stateless   = false
    },    
    {
      description = "Allow path discovery from worker nodes"
      protocol    = local.icmp_protocol,
      port        = -1,
      source      = local.anywhere,
      stateless   = false
    }
  ]
}

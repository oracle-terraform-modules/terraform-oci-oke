# Copyright 2017, 2021 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {

  # first vcn cidr
  # pick the first cidr block in the list as this is where we will create the oke subnets
  vcn_cidr = element(data.oci_core_vcn.vcn.cidr_blocks,0)

  # subnet cidrs - used by subnets
  bastion_subnet = cidrsubnet(local.vcn_cidr, lookup(var.subnets["bastion"], "newbits"), lookup(var.subnets["bastion"], "netnum"))

  cp_subnet = cidrsubnet(local.vcn_cidr, lookup(var.subnets["cp"], "newbits"), lookup(var.subnets["cp"], "netnum"))

  int_lb_subnet = cidrsubnet(local.vcn_cidr, lookup(var.subnets["int_lb"], "newbits"), lookup(var.subnets["int_lb"], "netnum"))

  operator_subnet = cidrsubnet(local.vcn_cidr, lookup(var.subnets["operator"], "newbits"), lookup(var.subnets["operator"], "netnum"))

  pub_lb_subnet = cidrsubnet(local.vcn_cidr, lookup(var.subnets["pub_lb"], "newbits"), lookup(var.subnets["pub_lb"], "netnum"))

  workers_subnet = cidrsubnet(local.vcn_cidr, lookup(var.subnets["workers"], "newbits"), lookup(var.subnets["workers"], "netnum"))

  anywhere = "0.0.0.0/0"

  # port numbers
  node_port_min = 30000

  node_port_max = 32767

  ssh_port = 22

  # protocols
  # # special OCI value for all protocols
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
      description      = "Allow OCI Bastion service to communicate with the OKE control plane",
      destination      = local.cp_subnet,
      destination_type = "CIDR_BLOCK",
      protocol         = local.tcp_protocol,
      port             = 6443,
      stateless        = false
    },
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
      destination      = local.workers_subnet,
      destination_type = "CIDR_BLOCK",
      protocol         = local.tcp_protocol,
      port             = -1,
      stateless        = false
    },
    {
      description      = "Allow path discovery to worker nodes",
      destination      = local.workers_subnet,
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
      source      = local.workers_subnet,
      stateless   = false
    },
    {
      description = "Allow worker nodes to control plane communication"
      protocol    = local.tcp_protocol,
      port        = 12250,
      source      = local.workers_subnet,
      stateless   = false
    },
    {
      description = "Allow path discovery from worker nodes"
      protocol    = local.icmp_protocol,
      port        = -1,
      source      = local.workers_subnet,
      stateless   = false
    },
    {
      description = "Allow operator host access to control plane. Required for kubectl/helm."
      protocol    = local.tcp_protocol,
      port        = 6443,
      source      = local.operator_subnet,
      stateless   = false
    },
  ]

  # workers
  workers_egress = [
    {
      description      = "Allow egress for all traffic to allow pods to communicate between each other on different worker nodes on the worker subnet",
      destination      = local.workers_subnet,
      destination_type = "CIDR_BLOCK",
      protocol         = local.all_protocols,
      port             = -1,
      stateless        = false
    },
    {
      description      = "Allow path discovery",
      destination      = local.anywhere,
      destination_type = "CIDR_BLOCK",
      protocol         = local.icmp_protocol,
      port             = -1,
      stateless        = false
    },
    {
      description      = "Allow worker nodes to communicate with OKE",
      destination      = local.osn,
      destination_type = "SERVICE_CIDR_BLOCK",
      protocol         = local.tcp_protocol,
      port             = -1,
      stateless        = false
    },
    {
      description      = "Allow worker nodes to control plane API endpoint communication",
      destination      = local.cp_subnet,
      destination_type = "CIDR_BLOCK",
      protocol         = local.tcp_protocol,
      port             = 6443,
      stateless        = false
    },
    {
      description      = "Allow worker nodes to control plane communication",
      destination      = local.cp_subnet,
      destination_type = "CIDR_BLOCK",
      protocol         = local.tcp_protocol,
      port             = 12250,
      stateless        = false
    }
  ]

  workers_ingress = [
    {
      description = "Allow ingress for all traffic to allow pods to communicate between each other on different worker nodes on the worker subnet",
      protocol    = local.all_protocols,
      min_port        = -1,
      max_port        = -1,
      source      = local.workers_subnet,
      stateless   = false
    },
    {
      description = "Allow control plane to communicate with worker nodes on ports 1-10",
      protocol    = local.tcp_protocol,
      min_port        = 1,
      max_port        = 10,
      source      = local.cp_subnet,
      stateless   = false
    },
    {
      description = "Allow control plane to communicate with worker nodes on port(s) 12-16",
      protocol    = local.tcp_protocol,
      min_port        = 12,
      max_port        = 16,
      source      = local.cp_subnet,
      stateless   = false
    },
    {
      description = "Allow control plane to communicate with worker nodes on port(s) 12-16",
      protocol    = local.tcp_protocol,
      min_port    = 22,
      max_port    = 22,
      source      = local.cp_subnet,
      stateless   = false
    },
    {
      description = "Allow control plane to communicate with worker nodes on port(s) 22",
      protocol    = local.tcp_protocol,
      min_port    = 22,
      max_port    = 22,
      source      = local.cp_subnet,
      stateless   = false
    },
    {
      description = "Allow control plane to communicate with worker nodes on port(s) 26-42",
      protocol    = local.tcp_protocol,
      min_port    = 26,
      max_port    = 42,
      source      = local.cp_subnet,
      stateless   = false
    },
    {
      description = "Allow control plane to communicate with worker nodes on port(s) 26-42",
      protocol    = local.tcp_protocol,
      min_port    = 26,
      max_port    = 42,
      source      = local.cp_subnet,
      stateless   = false
    },
    {
      description = "Allow control plane to communicate with worker nodes on port(s) 44-48",
      protocol    = local.tcp_protocol,
      min_port    = 44,
      max_port    = 48,
      source      = local.cp_subnet,
      stateless   = false
    },
    {
      description = "Allow control plane to communicate with worker nodes on port(s) 50-52",
      protocol    = local.tcp_protocol,
      min_port    = 50,
      max_port    = 52,
      source      = local.cp_subnet,
      stateless   = false
    },
    {
      description = "Allow control plane to communicate with worker nodes on port(s) 54-69",
      protocol    = local.tcp_protocol,
      min_port    = 54,
      max_port    = 69,
      source      = local.cp_subnet,
      stateless   = false
    },
    {
      description = "Allow control plane to communicate with worker nodes on port(s) 75-78",
      protocol    = local.tcp_protocol,
      min_port    = 75,
      max_port    = 78,
      source      = local.cp_subnet,
      stateless   = false
    },
    {
      # exceptional rule!
      description = "Allow control plane to communicate with worker nodes on port(s) 80",
      protocol    = local.tcp_protocol,
      min_port    = 80,
      max_port    = 80,
      source      = local.cp_subnet,
      stateless   = false
    },
    {
      description = "Allow control plane to communicate with worker nodes on port(s) 82-87",
      protocol    = local.tcp_protocol,
      min_port    = 82,
      max_port    = 87,
      source      = local.cp_subnet,
      stateless   = false
    },
    {
      description = "Allow control plane to communicate with worker nodes on port(s) 89-110",
      protocol    = local.tcp_protocol,
      min_port    = 89,
      max_port    = 110,
      source      = local.cp_subnet,
      stateless   = false
    },
    {
      description = "Allow control plane to communicate with worker nodes on port(s) 112-122",
      protocol    = local.tcp_protocol,
      min_port    = 112,
      max_port    = 122,
      source      = local.cp_subnet,
      stateless   = false
    },
    {
      description = "Allow control plane to communicate with worker nodes on port(s) 124-388",
      protocol    = local.tcp_protocol,
      min_port    = 124,
      max_port    = 388,
      source      = local.cp_subnet,
      stateless   = false
    },
    {
      description = "Allow control plane to communicate with worker nodes on port(s) 390-444",
      protocol    = local.tcp_protocol,
      min_port    = 390,
      max_port    = 444,
      source      = local.cp_subnet,
      stateless   = false
    },
    {
      description = "Allow control plane to communicate with worker nodes on port(s) 446-499",
      protocol    = local.tcp_protocol,
      min_port    = 446,
      max_port    = 499,
      source      = local.cp_subnet,
      stateless   = false
    },
    {
      description = "Allow control plane to communicate with worker nodes on port(s) 501-635",
      protocol    = local.tcp_protocol,
      min_port    = 501,
      max_port    = 635,
      source      = local.cp_subnet,
      stateless   = false
    },
    {
      description = "Allow control plane to communicate with worker nodes on port(s) 637-3305",
      protocol    = local.tcp_protocol,
      min_port    = 637,
      max_port    = 3305,
      source      = local.cp_subnet,
      stateless   = false
    },
    {
      description = "Allow control plane to communicate with worker nodes on port(s) 637-3305",
      protocol    = local.tcp_protocol,
      min_port    = 637,
      max_port    = 3305,
      source      = local.cp_subnet,
      stateless   = false
    },
    {
      description = "Allow control plane to communicate with worker nodes on port(s) 3307-3388",
      protocol    = local.tcp_protocol,
      min_port    = 3307,
      max_port    = 3388,
      source      = local.cp_subnet,
      stateless   = false
    },
    {
      description = "Allow control plane to communicate with worker nodes on port(s) 3390-5900",
      protocol    = local.tcp_protocol,
      min_port    = 3390,
      max_port    = 5900,
      source      = local.cp_subnet,
      stateless   = false
    },
    {
      description = "Allow control plane to communicate with worker nodes on port(s) 5902-5984",
      protocol    = local.tcp_protocol,
      min_port    = 5902,
      max_port    = 5984,
      source      = local.cp_subnet,
      stateless   = false
    },
    {
      description = "Allow control plane to communicate with worker nodes on port(s) 5987-7000",
      protocol    = local.tcp_protocol,
      min_port    = 5987,
      max_port    = 7000,
      source      = local.cp_subnet,
      stateless   = false
    },
    {
      description = "Allow control plane to communicate with worker nodes on port(s) 7002-7999",
      protocol    = local.tcp_protocol,
      min_port    = 7002,
      max_port    = 7999,
      source      = local.cp_subnet,
      stateless   = false
    },
    {
      # exceptional rule!
      description = "Allow control plane to communicate with worker nodes on port(s) 8000",
      protocol    = local.tcp_protocol,
      min_port    = 8000,
      max_port    = 8000,
      source      = local.cp_subnet,
      stateless   = false
    },
    {
      description = "Allow control plane to communicate with worker nodes on port(s) 8001-8079",
      protocol    = local.tcp_protocol,
      min_port    = 8001,
      max_port    = 8079,
      source      = local.cp_subnet,
      stateless   = false
    },
    {
      # exceptional rule!
      description = "Allow control plane to communicate with worker nodes on port(s) 8080",
      protocol    = local.tcp_protocol,
      min_port    = 8080,
      max_port    = 8080,
      source      = local.cp_subnet,
      stateless   = false
    },
    {
      description = "Allow control plane to communicate with worker nodes on port(s) 8081-8442",
      protocol    = local.tcp_protocol,
      min_port    = 8081,
      max_port    = 8442,
      source      = local.cp_subnet,
      stateless   = false
    },
    {
      description = "Allow control plane to communicate with worker nodes on port(s) 8444-8888",
      protocol    = local.tcp_protocol,
      min_port    = 8444,
      max_port    = 8887,
      source      = local.cp_subnet,
      stateless   = false
    },
    {
      # exceptional rule!
      description = "Allow control plane to communicate with worker nodes on port(s) 8888",
      protocol    = local.tcp_protocol,
      min_port    = 8888,
      max_port    = 8888,
      source      = local.cp_subnet,
      stateless   = false
    },
    {
      # registered ports
      description = "Allow control plane to communicate with worker nodes on port(s) 8889-49151",
      protocol    = local.tcp_protocol,
      min_port    = 8889,
      max_port    = 49151,
      source      = local.cp_subnet,
      stateless   = false
    },
    {
      # dynamic ports
      description = "Allow control plane to communicate with worker nodes on port(s) 8889-49151",
      protocol    = local.tcp_protocol,
      min_port    = 49151,
      max_port    = 65535,
      source      = local.cp_subnet,
      stateless   = false
    },
    {
      description = "Allow path discovery from worker nodes"
      protocol    = local.icmp_protocol,
      min_port    = -1,
      max_port    = -1,
      source      = local.anywhere,
      stateless   = false
    },
  ]
}

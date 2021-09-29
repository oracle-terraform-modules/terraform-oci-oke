# Copyright 2017, 2021 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {

  # first vcn cidr
  # pick the first cidr block in the list as this is where we will create the oke subnets
  vcn_cidr = element(data.oci_core_vcn.vcn.cidr_blocks, 0)

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
      source_type = "CIDR_BLOCK",
      stateless   = false
    },
    {
      description = "Allow worker nodes to control plane communication"
      protocol    = local.tcp_protocol,
      port        = 12250,
      source      = local.workers_subnet,
      source_type = "CIDR_BLOCK",
      stateless   = false
    },
    {
      description = "Allow path discovery from worker nodes"
      protocol    = local.icmp_protocol,
      port        = -1,
      source      = local.workers_subnet,
      source_type = "CIDR_BLOCK",
      stateless   = false
    },
    {
      description = "Allow operator host access to control plane. Required for kubectl/helm."
      protocol    = local.tcp_protocol,
      port        = 6443,
      source      = local.operator_subnet,
      source_type = "CIDR_BLOCK",
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
      description      = "Allow worker nodes to communicate with OSN so applications can use OCI Streaming, Object Storage, Autonomous",
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
      port        = -1,
      source      = local.workers_subnet,
      source_type = "CIDR_BLOCK",
      stateless   = false
    },
    {
      description = "Allow control plane to communicate with worker nodes",
      protocol    = local.tcp_protocol,
      port        = -1,
      source      = local.cp_subnet,
      source_type = "CIDR_BLOCK",
      stateless   = false
    },
    {
      description = "Allow path discovery from worker nodes"
      protocol    = local.icmp_protocol,
      port        = -1,
      source      = local.anywhere,
      source_type = "CIDR_BLOCK",
      stateless   = false
    }
  ]

  int_lb_egress = [
    {
      description      = "Allow stateful egress to workers. Required for NodePorts and load balancer http/tcp health checks",
      destination      = local.workers_subnet,
      destination_type = "CIDR_BLOCK",
      protocol         = local.tcp_protocol,
      port             = "30000-32767",
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

  # Allow ingress from the supplied allow list and the public load balancer subnet
  internal_lb_allowed_list = concat(var.internal_lb_allowed_list, tolist([local.pub_lb_subnet]))

  internal_lb_allowed_list_and_ports = setproduct(local.internal_lb_allowed_list, var.internal_lb_allowed_ports)

  pub_lb_egress = [
    {
      description      = "Allow stateful egress to internal load balancers subnet.",
      destination      = local.int_lb_subnet,
      destination_type = "CIDR_BLOCK",
      protocol         = local.tcp_protocol,
      port             = 80
      stateless        = false
    },
    {
      description      = "Allow stateful egress to internal load balancers subnet.",
      destination      = local.int_lb_subnet,
      destination_type = "CIDR_BLOCK",
      protocol         = local.tcp_protocol,
      port             = 443
      stateless        = false
    },
    {
      description      = "Allow stateful egress to workers. Required for NodePorts and load balancer http/tcp health checks",
      destination      = local.workers_subnet,
      destination_type = "CIDR_BLOCK",
      protocol         = local.tcp_protocol,
      port             = "30000-32767",
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

  public_lb_allowed_list_and_ports = setproduct(var.public_lb_allowed_list, var.public_lb_allowed_ports)
}

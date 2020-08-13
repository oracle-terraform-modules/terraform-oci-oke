# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {

  # subnet cidrs - used by subnets
  bastion_subnet = cidrsubnet(var.oke_network_vcn.vcn_cidr, var.oke_network_vcn.newbits["bastion"], var.oke_network_vcn.netnum["bastion"])
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

  # public workers ingress
  # # if port = -1, allow all ports

  worker_egress = [
    {
      description      = "Allow egress for all traffic to allow pods to communicate between each other on different worker nodes on the worker subnet",
      destination      = local.worker_subnet,
      destination_type = "CIDR_BLOCK",
      protocol         = local.all_protocols,
      port             = "-1",
      stateless        = "false"
    },
    {
      description      = "Allow ICMP traffic to Oracle Services Network",
      destination      = local.osn,
      destination_type = "SERVICE_CIDR_BLOCK",
      protocol         = tostring(local.icmp_protocol),
      port             = "-1",
      stateless        = "false"
    },
    {
      description      = "Allow TCP traffic to Oracle Services Network to enable worker nodes to communicate with OKE to ensure correct start-up, and continued functioning",
      destination      = local.osn,
      destination_type = "SERVICE_CIDR_BLOCK",
      protocol         = tostring(local.tcp_protocol),
      port             = "80",
      stateless        = "false"
    },
    {
      description      = "Allow TCP traffic to Oracle Services Network to enable worker nodes to communicate with OKE to ensure correct start-up, and continued functioning",
      destination      = local.osn,
      destination_type = "SERVICE_CIDR_BLOCK",
      protocol         = tostring(local.tcp_protocol),
      port             = "443",
      stateless        = "false"
    },
    {
      description      = "Allow TCP traffic to Oracle Services Network to enable worker nodes to communicate with OKE to ensure correct start-up, and continued functioning",
      destination      = local.osn,
      destination_type = "SERVICE_CIDR_BLOCK",
      protocol         = tostring(local.tcp_protocol),
      port             = "6443",
      stateless        = "false"
    },
    {
      description      = "Allow TCP traffic to Oracle Services Network to enable worker nodes to communicate with OKE to ensure correct start-up, and continued functioning",
      destination      = local.osn,
      destination_type = "SERVICE_CIDR_BLOCK",
      protocol         = tostring(local.tcp_protocol),
      port             = "12250",
      stateless        = "false"
    },
  ]

  public_worker_ingress = [
    {
      description = "Allow ingress for all traffic to allow pods to communicate between each other on different worker nodes on the worker subnet",
      protocol    = local.all_protocols,
      port        = -1,
      source      = local.worker_subnet,
      stateless   = false
    },
    {
      description = "Allow OKE to access worker nodes",
      protocol    = local.tcp_protocol,
      port        = local.ssh_port,
      source      = "130.35.0.0/16",
      stateless   = false
    },
    {
      description = "Allow OKE to access worker nodes",
      protocol    = local.tcp_protocol,
      port        = local.ssh_port,
      source      = "134.70.0.0/17",
      stateless   = false
    },
    {
      description = "Allow OKE to access worker nodes",
      protocol    = local.tcp_protocol,
      port        = local.ssh_port,
      source      = "138.1.0.0/16",
      stateless   = false
    },
    {
      description = "Allow OKE to access worker nodes",
      protocol    = local.tcp_protocol,
      port        = local.ssh_port,
      source      = "140.91.0.0/17",
      stateless   = false
    },
    {
      description = "Allow OKE to access worker nodes",
      protocol    = local.tcp_protocol,
      port        = local.ssh_port,
      source      = "192.29.0.0/16",
      stateless   = false
    },
  ]


  waf_cidr_blocks = [

    "130.35.0.0/20", "130.35.112.0/22", "130.35.120.0/21", "130.35.128.0/20", "130.35.144.0/20", "130.35.16.0/20",
    "130.35.176.0/20", "130.35.192.0/19", "130.35.224.0/22", "130.35.232.0/21", "130.35.240.0/20", "130.35.48.0/20",
    "130.35.64.0/19", "130.35.96.0/20", "138.1.0.0/20", "138.1.104.0/22", "138.1.128.0/19", "138.1.16.0/20",
    "138.1.160.0/19", "138.1.192.0/20", "138.1.208.0/20", "138.1.224.0/19", "138.1.32.0/21", "138.1.40.0/21",
    "138.1.48.0/21", "138.1.64.0/20", "138.1.80.0/20", "138.1.96.0/21", "147.154.0.0/18", "147.154.128.0/18",
    "147.154.192.0/20", "147.154.208.0/21", "147.154.224.0/19", "147.154.64.0/20", "147.154.80.0/21", "147.154.96.0/19",
    "192.157.18.0/23", "192.29.0.0/20", "192.29.128.0/21", "192.29.144.0/21", "192.29.16.0/21", "192.29.32.0/21",
    "192.29.48.0/21", "192.29.56.0/21", "192.29.64.0/20", "192.29.96.0/20", "192.69.118.0/23", "198.181.48.0/21",
    "199.195.6.0/23", "205.147.88.0/21"
  ]
}

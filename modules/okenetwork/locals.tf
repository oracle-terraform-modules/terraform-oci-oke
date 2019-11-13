# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

locals {
  # subnet cidrs - used by subnets
  int_lb_subnet = cidrsubnet(var.oke_network_vcn.vcn_cidr, var.oke_network_vcn.newbits["lb"], var.oke_network_vcn.netnum["int_lb"])
  pub_lb_subnet = cidrsubnet(var.oke_network_vcn.vcn_cidr, var.oke_network_vcn.newbits["lb"], var.oke_network_vcn.netnum["pub_lb"])
  worker_subnet = cidrsubnet(var.oke_network_vcn.vcn_cidr, var.oke_network_vcn.newbits["workers"], var.oke_network_vcn.netnum["workers"])

  # security rules locals - used by security
  all_protocols = "all"

  anywhere = "0.0.0.0/0"

  icmp_protocol = 1

  pub_cidr_blocks = ["130.35.0.0/16", "134.70.0.0/17", "138.1.0.0/16", "140.91.0.0/17", "147.154.0.0/16", "192.29.0.0/16", "0.0.0.0/0"]

  node_port_min = 30000

  node_port_max = 32767

  ssh_port = 22

  tcp_protocol = 6

}

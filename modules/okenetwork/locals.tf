# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

locals {
  # subnet cidrs - used by subnets
  int_subnet_ad1    = cidrsubnet(var.oke_network_vcn.vcn_cidr, var.oke_network_vcn.newbits["lb"], var.oke_network_vcn.subnets["int_lb_ad1"])
  
  int_subnet_ad2    = cidrsubnet(var.oke_network_vcn.vcn_cidr, var.oke_network_vcn.newbits["lb"], var.oke_network_vcn.subnets["int_lb_ad2"])
  
  int_subnet_ad3    = cidrsubnet(var.oke_network_vcn.vcn_cidr, var.oke_network_vcn.newbits["lb"], var.oke_network_vcn.subnets["int_lb_ad3"])
  
  pub_subnet_ad1    = cidrsubnet(var.oke_network_vcn.vcn_cidr, var.oke_network_vcn.newbits["lb"], var.oke_network_vcn.subnets["pub_lb_ad1"])
  
  pub_subnet_ad2    = cidrsubnet(var.oke_network_vcn.vcn_cidr, var.oke_network_vcn.newbits["lb"], var.oke_network_vcn.subnets["pub_lb_ad2"])
  
  pub_subnet_ad3    = cidrsubnet(var.oke_network_vcn.vcn_cidr, var.oke_network_vcn.newbits["lb"], var.oke_network_vcn.subnets["pub_lb_ad3"])
  
  worker_subnet_ad1 = cidrsubnet(var.oke_network_vcn.vcn_cidr, var.oke_network_vcn.newbits["workers"], var.oke_network_vcn.subnets["workers_ad1"])
  
  worker_subnet_ad2 = cidrsubnet(var.oke_network_vcn.vcn_cidr, var.oke_network_vcn.newbits["workers"], var.oke_network_vcn.subnets["workers_ad2"])
  
  worker_subnet_ad3 = cidrsubnet(var.oke_network_vcn.vcn_cidr, var.oke_network_vcn.newbits["workers"], var.oke_network_vcn.subnets["workers_ad3"])


  # security rules locals - used by security
  all_protocols   = "all"

  anywhere        = "0.0.0.0/0"

  icmp_protocol   = 1

  pub_cidr_blocks = ["130.35.0.0/16", "134.70.0.0/17", "138.1.0.0/16", "140.91.0.0/17", "147.154.0.0/16", "192.29.0.0/16", "0.0.0.0/0"]

  node_port_min   = 30000

  node_port_max   = 32767

  ssh_port        = 22

  tcp_protocol    = 6

  worker_subnets  = list(local.worker_subnet_ad1, local.worker_subnet_ad2, local.worker_subnet_ad3)

}
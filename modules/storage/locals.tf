# Copyright 2017, 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {

  #IANA protocol numbers
  tcp_protocol = 6

  udp_protocol = 17

  availability_domain = data.oci_identity_availability_domain.ad.name

  vcn_cidr = element(data.oci_core_vcn.vcn.cidr_blocks, 0)

  workers_subnet = cidrsubnet(local.vcn_cidr, lookup(var.subnets["workers"], "newbits"), lookup(var.subnets["workers"], "netnum"))

  fss_subnet = cidrsubnet(local.vcn_cidr, lookup(var.subnets["fss"], "newbits"), lookup(var.subnets["fss"], "netnum"))

  # fss mount target security rules
  ## ingress rule for TCP and UDP protocol
  fss_mt_ingress = [
    {
      description = "Allow ingress UDP traffic from OKE worker subnet to port 111 on FSS (Mount Target) subnet",
      protocol    = local.udp_protocol,
      port        = 111,
      source      = local.workers_subnet,
      source_type = "CIDR_BLOCK",
      stateless   = false
    },
    {
      description = "Allow ingress UDP traffic from OKE worker subnet to port 2048 on FSS (Mount Target) subnet",
      protocol    = local.udp_protocol,
      port        = 2048,
      source      = local.workers_subnet,
      source_type = "CIDR_BLOCK",
      stateless   = false
    },
    {
      description = "Allow ingress TCP traffic from OKE worker subnet to port 111 on FSS (Mount Target) subnet",
      protocol    = local.tcp_protocol,
      port        = 111,
      source      = local.workers_subnet,
      source_type = "CIDR_BLOCK",
      stateless   = false
    },
    {
      description = "Allow ingress TCP traffic from OKE worker subnet to port 2048 on FSS (Mount Target) subnet",
      protocol    = local.tcp_protocol,
      port        = 2048,
      source      = local.workers_subnet,
      source_type = "CIDR_BLOCK",
      stateless   = false
    },
    {
      description = "Allow ingress TCP traffic from OKE worker subnet to port 2049 on FSS (Mount Target) subnet",
      protocol    = local.tcp_protocol,
      port        = 2049,
      source      = local.workers_subnet,
      source_type = "CIDR_BLOCK",
      stateless   = false
    },
    {
      description = "Allow ingress TCP traffic from OKE worker subnet to port 2050 on FSS (Mount Target) subnet",
      protocol    = local.tcp_protocol,
      port        = 2050,
      source      = local.workers_subnet,
      source_type = "CIDR_BLOCK",
      stateless   = false
    },
  ]

  ## egress rule for TCP and UDP protocol
  fss_mt_egress = [
    {
      description      = "Allow egress UDP traffic from FSS (Mount Target) subnet to port 111 on OKE worker subnet",
      destination      = local.workers_subnet,
      destination_type = "CIDR_BLOCK",
      protocol         = local.udp_protocol,
      port             = "111",
      stateless        = "false"
    },
    {
      description      = "Allow egress TCP traffic from FSS (Mount Target) subnet to port 111 on OKE worker subnet",
      destination      = local.workers_subnet,
      destination_type = "CIDR_BLOCK",
      protocol         = local.tcp_protocol,
      port             = "111",
      stateless        = "false"
    },
    {
      description      = "Allow egress TCP traffic from FSS (Mount Target) subnet to port 2048 on OKE worker subnet",
      destination      = local.workers_subnet,
      destination_type = "CIDR_BLOCK",
      protocol         = local.tcp_protocol,
      port             = "2048",
      stateless        = "false"
    },
    {
      description      = "Allow egress TCP traffic from FSS (Mount Target) subnet to port 2049 on OKE worker subnet",
      destination      = local.workers_subnet,
      destination_type = "CIDR_BLOCK",
      protocol         = local.tcp_protocol,
      port             = "2049",
      stateless        = "false"
    },
    {
      description      = "Allow egress TCP traffic from FSS (Mount Target) subnet to port 2050 on OKE worker subnet",
      destination      = local.workers_subnet,
      destination_type = "CIDR_BLOCK",
      protocol         = local.tcp_protocol,
      port             = "2050",
      stateless        = "false"
    },
  ]


}

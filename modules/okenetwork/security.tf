# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

locals {
  icmp_protocol = 1
  tcp_protocol  = 6
  all_protocols = "all"

  anywhere = "0.0.0.0/0"

  ssh_port = 22

  node_port_min = 30000
  node_port_max = 32767
}

# worker security checklist
resource "oci_core_security_list" "workers_seclist" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "${var.label_prefix}-workers security list"
  vcn_id         = "${var.vcn_id}"

  egress_security_rules = [
    {
      # intra-vcn
      protocol    = "${local.all_protocols}"
      destination = "${var.vcn_cidr}"
      stateless   = true
    },
    {
      # outbound
      protocol    = "${local.all_protocols}"
      destination = "${local.anywhere}"
      stateless   = false
    },
  ]

  ingress_security_rules = [
    {
      # intra-vcn
      protocol  = "all"
      source    = "${var.vcn_cidr}"
      stateless = true
    },
    {
      # icmp
      protocol  = "${local.icmp_protocol}"
      source    = "${local.anywhere}"
      stateless = false
    },
    {
      # rule 5
      protocol  = "${local.tcp_protocol}"
      source    = "130.35.0.0/16"
      stateless = false

      tcp_options = {
        "max" = "${local.ssh_port}"
        "min" = "${local.ssh_port}"
      }
    },
    {
      # rule 6
      protocol  = "${local.tcp_protocol}"
      source    = "134.70.0.0/17"
      stateless = false

      tcp_options = {
        "max" = "${local.ssh_port}"
        "min" = "${local.ssh_port}"
      }
    },
    {
      # rule 7
      protocol  = "${local.tcp_protocol}"
      source    = "138.1.0.0/17"
      stateless = false

      tcp_options = {
        "max" = "${local.ssh_port}"
        "min" = "${local.ssh_port}"
      }
    },
    {
      # rule 8
      protocol = "${local.tcp_protocol}"
      source    = "140.91.0.0/17"
      stateless = false

      tcp_options = {
        "max" = "${local.ssh_port}"
        "min" = "${local.ssh_port}"
      }
    },    
    {
      # rule 9
      protocol  = "${local.tcp_protocol}"
      source    = "147.154.0.0/16"
      stateless = false

      tcp_options = {
        "max" = "${local.ssh_port}"
        "min" = "${local.ssh_port}"
      }
    },
    {
      # rule 10
      protocol  = "${local.tcp_protocol}"
      source    = "192.29.0.0/16"
      stateless = false

      tcp_options = {
        "max" = "${local.ssh_port}"
        "min" = "${local.ssh_port}"
      }
    },
    {
      # rule 11
      protocol  = "${local.tcp_protocol}"
      source    = "${local.anywhere}"
      stateless = false

      tcp_options = {
        "max" = "${local.ssh_port}"
        "min" = "${local.ssh_port}"
      }
    },
    {
      # rule 12
      protocol  = "${local.tcp_protocol}"
      source    = "${local.anywhere}"
      stateless = false

      tcp_options = {
        "max" = "${local.node_port_max}"
        "min" = "${local.node_port_min}"
      }
    },
  ]
}

# load balancer security checklist
resource "oci_core_security_list" "lb_seclist" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "${var.label_prefix}-load balancer security list"
  vcn_id         = "${var.vcn_id}"

  egress_security_rules = [{
    protocol    = "${local.all_protocols}"
    destination = "${local.anywhere}"
    stateless   = true
  }]

  ingress_security_rules = [
    {
      protocol  = "${local.tcp_protocol}"
      source    = "${local.anywhere}"
      stateless = true
    },
  ]
}

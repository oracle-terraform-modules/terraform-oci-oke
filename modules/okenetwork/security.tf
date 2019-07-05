# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

locals {
  all_protocols   = "all"
  anywhere        = "0.0.0.0/0"
  icmp_protocol   = 1
  oke_cidr_blocks = ["130.35.0.0/16", "134.70.0.0/17", "138.1.0.0/16", "140.91.0.0/17", "147.154.0.0/16", "192.29.0.0/16", "0.0.0.0/0"]
  node_port_min   = 30000
  node_port_max   = 32767
  ssh_port        = 22
  tcp_protocol    = 6
  worker_subnets  = list(local.worker_subnet_ad1, local.worker_subnet_ad2, local.worker_subnet_ad3)
}

# worker security checklist
resource "oci_core_security_list" "workers_seclist" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.label_prefix}-workers security list"
  vcn_id         = var.vcn_id

  dynamic "egress_security_rules" {
    # rules 1-3
    iterator = worker_iterator
    for_each = local.worker_subnets

    content {
      destination = worker_iterator.value
      protocol    = local.all_protocols
      stateless   = true
    }
  }

  egress_security_rules {
    # rule 4
    destination = local.anywhere
    protocol    = local.all_protocols
    stateless   = false
  }

  dynamic "egress_security_rules" {
    # for oracle services
    for_each = var.is_service_gateway_enabled == true ? list(1) : []

    content {
      destination      = lookup(data.oci_core_services.all_oci_services[0].services[0], "cidr_block")
      destination_type = "SERVICE_CIDR_BLOCK"
      protocol         = local.all_protocols
      stateless        = false
    }
  }

  dynamic "ingress_security_rules" {
    # rules 1-3
    iterator = worker_iterator
    for_each = local.worker_subnets

    content {
      protocol  = local.all_protocols
      source    = worker_iterator.value
      stateless = true
    }
  }

  ingress_security_rules {
    # rule 4
    protocol  = local.icmp_protocol
    source    = local.anywhere
    stateless = false
  }

  dynamic "ingress_security_rules" {
    # rules 5-11
    iterator = cidr_iterator
    for_each = local.oke_cidr_blocks

    content {
      protocol  = local.tcp_protocol
      source    = cidr_iterator.value
      stateless = false

      tcp_options {
        max = local.ssh_port
        min = local.ssh_port
      }
    }
  }

  ingress_security_rules {
    # rule 12
    protocol  = local.tcp_protocol
    source    = local.anywhere
    stateless = false

    tcp_options {
      max = local.node_port_max
      min = local.node_port_min
    }
  }
}

# load balancer security checklist
resource "oci_core_security_list" "lb_seclist" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.label_prefix}-load balancer security list"
  vcn_id         = var.vcn_id

  egress_security_rules {
    protocol    = local.all_protocols
    destination = local.anywhere
    stateless   = true
  }

  ingress_security_rules {
    protocol  = local.tcp_protocol
    source    = local.anywhere
    stateless = true
  }
}
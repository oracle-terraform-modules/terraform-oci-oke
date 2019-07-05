# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

locals {
  all_protocols = "all"

  anywhere = "0.0.0.0/0"

  icmp_protocol = 1

  node_port_min = 30000
  
  node_port_max = 32767

  ssh_port = 22

  tcp_protocol  = 6

}

# worker security checklist
resource "oci_core_security_list" "workers_seclist" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.label_prefix}-workers security list"
  vcn_id         = var.vcn_id

  egress_security_rules {
    # intra-vcn
    protocol    = local.all_protocols
    destination = var.vcn_cidr
    stateless   = true
  }

  egress_security_rules {
    # outbound
    protocol    = local.all_protocols
    destination = local.anywhere
    stateless   = false
  }

  dynamic "egress_security_rules" {
    # for oracle services
    for_each = var.is_service_gateway_enabled == true ? list(1) : []

    content {   
      destination      = lookup(data.oci_core_services.all_oci_services[0].services[0], "cidr_block")
      destination_type = "SERVICE_CIDR_BLOCK"
      protocol    = local.all_protocols
      stateless   = false
    }
  }  

  ingress_security_rules {
    # intra-vcn
    protocol  = "all"
    source    = var.vcn_cidr
    stateless = true
  }
  ingress_security_rules {
    # icmp
    protocol  = local.icmp_protocol
    source    = local.anywhere
    stateless = false
  }
  ingress_security_rules {
    # rule 5
    protocol  = local.tcp_protocol
    source    = "130.35.0.0/16"
    stateless = false

    tcp_options {
      max = local.ssh_port
      min = local.ssh_port
    }
  }
  ingress_security_rules {
    # rule 6
    protocol  = local.tcp_protocol
    source    = "134.70.0.0/17"
    stateless = false

    tcp_options {
      max = local.ssh_port
      min = local.ssh_port
    }
  }
  ingress_security_rules {
    # rule 7
    protocol  = local.tcp_protocol
    source    = "138.1.0.0/17"
    stateless = false

    tcp_options {
      max = local.ssh_port
      min = local.ssh_port
    }
  }
  ingress_security_rules {
    # rule 8
    protocol  = local.tcp_protocol
    source    = "140.91.0.0/17"
    stateless = false

    tcp_options {
      max = local.ssh_port
      min = local.ssh_port
    }
  }
  ingress_security_rules {
    # rule 9
    protocol  = local.tcp_protocol
    source    = "147.154.0.0/16"
    stateless = false

    tcp_options {
      max = local.ssh_port
      min = local.ssh_port
    }
  }
  ingress_security_rules {
    # rule 10
    protocol  = local.tcp_protocol
    source    = "192.29.0.0/16"
    stateless = false

    tcp_options {
      max = local.ssh_port
      min = local.ssh_port
    }
  }
  ingress_security_rules {
    # rule 11
    protocol  = local.tcp_protocol
    source    = local.anywhere
    stateless = false

    tcp_options {
      max = local.ssh_port
      min = local.ssh_port
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
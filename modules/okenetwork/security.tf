# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# public worker security checklist
resource "oci_core_security_list" "public_workers_seclist" {
  compartment_id = var.compartment_id
  display_name   = "${var.oke_general.label_prefix}-public-workers"
  vcn_id         = var.oke_network_vcn.vcn_id

  dynamic "egress_security_rules" {
    # stateless egress for all traffic between worker subnets rules 1-3
    iterator = worker_iterator
    for_each = [local.worker_subnet]

    content {
      destination = worker_iterator.value
      protocol    = local.all_protocols
      stateless   = true
    }
  }

  egress_security_rules {
    # egress that allows all outbound traffic to the internet rule 4
    destination = local.anywhere
    protocol    = local.all_protocols
    stateless   = false
  }

  dynamic "egress_security_rules" {
    # egress that allows traffic to oracle services through the service gateway
    for_each = var.oke_network_vcn.is_service_gateway_enabled == true ? list(1) : []

    content {
      destination      = lookup(data.oci_core_services.all_oci_services[0].services[0], "cidr_block")
      destination_type = "SERVICE_CIDR_BLOCK"
      protocol         = local.all_protocols
      stateless        = false
    }
  }

  dynamic "ingress_security_rules" {
    # stateless ingress for all traffic between worker subnets rules 1-3
    iterator = worker_iterator
    for_each = [local.worker_subnet]

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
    # stateful ingress for OKE access to worker nodes on port 22 from the 6 source CIDR blocks: rules 5-11
    iterator = cidr_iterator
    for_each = local.pub_cidr_blocks

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

  dynamic "ingress_security_rules" {
    # stateful ingress that allows NodePort access to the worker nodes rule 12
    for_each = var.oke_network_worker.allow_node_port_access == true ? list(1) : []

    content {
      protocol  = local.tcp_protocol
      source    = local.anywhere
      stateless = false

      tcp_options {
        max = local.node_port_max
        min = local.node_port_min
      }
    }
  }

  dynamic "ingress_security_rules" {
    # stateful ingress that allows ssh access to the worker nodes rule 13
    # when deployed in public mode, ssh access to the worker nodes is restricted through the bastion
    for_each = var.oke_network_worker.allow_worker_ssh_access == true ? list(1) : []

    content {
      protocol  = local.tcp_protocol
      source    = var.oke_network_vcn.vcn_cidr
      stateless = false

      tcp_options {
        max = local.ssh_port
        min = local.ssh_port
      }
    }
  }

  count = var.oke_network_worker.worker_mode == "private" ? 0 : 1
}

# private worker security checklist
resource "oci_core_security_list" "private_workers_seclist" {
  compartment_id = var.compartment_id
  display_name   = "${var.oke_general.label_prefix}-private-workers"
  vcn_id         = var.oke_network_vcn.vcn_id

  dynamic "egress_security_rules" {
    # stateless egress for all traffic between worker subnets rules 1-3
    iterator = worker_iterator
    for_each = [local.worker_subnet]

    content {
      destination = worker_iterator.value
      protocol    = local.all_protocols
      stateless   = true
    }
  }

  egress_security_rules {
    # egress that allows all outbound traffic to the internet rule 4
    destination = local.anywhere
    protocol    = local.all_protocols
    stateless   = false
  }

  dynamic "egress_security_rules" {
    # egress that allows traffic to oracle services through the service gateway
    for_each = var.oke_network_vcn.is_service_gateway_enabled == true ? list(1) : []

    content {
      destination      = lookup(data.oci_core_services.all_oci_services[0].services[0], "cidr_block")
      destination_type = "SERVICE_CIDR_BLOCK"
      protocol         = local.all_protocols
      stateless        = false
    }
  }

  dynamic "ingress_security_rules" {
    # stateless ingress for all traffic between worker subnets rules 1-3
    iterator = worker_iterator
    for_each = [local.worker_subnet]

    content {
      protocol  = local.all_protocols
      source    = worker_iterator.value
      stateless = true
    }
  }

  dynamic "ingress_security_rules" {
    # stateful ingress that allows ssh access to the worker nodes from within the vcn e.g. bastion rule 4
    for_each = var.oke_network_worker.allow_worker_ssh_access == true ? list(1) : []

    content {
      protocol  = local.tcp_protocol
      source    = var.oke_network_vcn.vcn_cidr
      stateless = false

      tcp_options {
        max = local.ssh_port
        min = local.ssh_port
      }
    }
  }

  count = var.oke_network_worker.worker_mode == "private" ? 1 : 0
}

# internal load balancer security checklist
resource "oci_core_security_list" "int_lb_seclist" {
  compartment_id = var.compartment_id
  display_name   = "${var.oke_general.label_prefix}-int-lb"
  vcn_id         = var.oke_network_vcn.vcn_id

  egress_security_rules {
    protocol    = local.all_protocols
    destination = local.anywhere
    stateless   = true
  }

  ingress_security_rules {
    protocol  = local.tcp_protocol
    source    = var.oke_network_vcn.vcn_cidr
    stateless = true
  }

  count = var.lb_subnet_type == "internal" || var.lb_subnet_type == "both" ? 1 : 0
}

# public load balancer security checklist
resource "oci_core_security_list" "pub_lb_seclist" {
  compartment_id = var.compartment_id
  display_name   = "${var.oke_general.label_prefix}-pub-lb"
  vcn_id         = var.oke_network_vcn.vcn_id

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

  count = var.lb_subnet_type == "public" || var.lb_subnet_type == "both" ? 1 : 0
}

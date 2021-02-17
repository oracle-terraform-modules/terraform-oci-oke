# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# public worker security checklist
resource "oci_core_security_list" "public_workers_seclist" {
  compartment_id = var.compartment_id
  display_name   = var.label_prefix == "none" ? "public-workers" : "${var.label_prefix}-public-workers"
  vcn_id         = var.oke_network_vcn.vcn_id

  dynamic "egress_security_rules" {
    iterator = worker_egress_iterator
    for_each = local.worker_egress

    content {
      description      = worker_egress_iterator.value["description"]
      destination      = worker_egress_iterator.value["destination"]
      destination_type = worker_egress_iterator.value["destination_type"]
      protocol         = worker_egress_iterator.value["protocol"] == "all" ? "all" : tonumber(worker_egress_iterator.value["protocol"])
      stateless        = tobool(worker_egress_iterator.value["stateless"])

      dynamic "tcp_options" {
        for_each = tonumber(worker_egress_iterator.value["port"]) == -1 ? [] : list(1)

        content {
          min = tonumber(worker_egress_iterator.value["port"])
          max = tonumber(worker_egress_iterator.value["port"])
        }
      }
    }
  }

  egress_security_rules {
    description = "Allow all outbound traffic to the internet. Required for getting container images or using external services"
    destination = local.anywhere
    protocol    = local.all_protocols
    stateless   = false
  }
  
  dynamic "ingress_security_rules" {
    iterator = public_worker_ingress_iterator
    for_each = local.public_worker_ingress

    content {
      description = public_worker_ingress_iterator.value["description"]
      protocol    = public_worker_ingress_iterator.value["protocol"] == "all" ? "all" : tonumber(public_worker_ingress_iterator.value["protocol"])
      source      = public_worker_ingress_iterator.value["source"]
      stateless   = tobool(public_worker_ingress_iterator.value["stateless"])

      dynamic "tcp_options" {
        for_each = tonumber(public_worker_ingress_iterator.value["port"]) == -1 ? [] : list(1)

        content {
          min = tonumber(public_worker_ingress_iterator.value["port"])
          max = tonumber(public_worker_ingress_iterator.value["port"])
        }
      }
    }
  }

  ingress_security_rules {
    description = "allow icmp from anywhere to enable worker nodes to receive Path MTU Discovery fragmentation messages"
    protocol    = local.icmp_protocol
    source      = local.anywhere
    stateless   = false

    icmp_options {
      type = 3
      code = 4
    }
  }

  dynamic "ingress_security_rules" {
    for_each = var.oke_network_worker.allow_node_port_access == true ? list(1) : []

    content {
      description = "allow tcp NodePorts access to workers"
      protocol    = local.tcp_protocol
      source      = local.anywhere
      stateless   = false

      tcp_options {
        max = local.node_port_max
        min = local.node_port_min
      }
    }
  }

  dynamic "ingress_security_rules" {
    for_each = var.oke_network_worker.allow_node_port_access == true ? list(1) : []

    content {
      description = "allow udp NodePorts access to workers"
      protocol    = local.udp_protocol
      source      = local.anywhere
      stateless   = false

      udp_options {
        max = local.node_port_max
        min = local.node_port_min
      }
    }
  }

  dynamic "ingress_security_rules" {
    for_each = var.oke_network_worker.allow_worker_ssh_access == true ? list(1) : []

    content {
      description = "allow ssh access to worker nodes through bastion"
      protocol    = local.tcp_protocol
      source      = local.bastion_subnet
      stateless   = false

      tcp_options {
        max = local.ssh_port
        min = local.ssh_port
      }
    }
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to ingress_security_rules,
      # because Kubernetes will dynamically add new ones based on
      # LoadBalancer requirements
      ingress_security_rules,
    ]
  }
  count = var.oke_network_worker.worker_mode == "private" ? 0 : 1
}

# private worker security checklist
resource "oci_core_security_list" "private_workers_seclist" {
  compartment_id = var.compartment_id
  display_name   = var.label_prefix == "none" ? "private-workers" :"${var.label_prefix}-private-workers"
  vcn_id         = var.oke_network_vcn.vcn_id

  dynamic "egress_security_rules" {
    iterator = worker_egress_iterator
    for_each = local.worker_egress

    content {
      description      = worker_egress_iterator.value["description"]
      destination      = worker_egress_iterator.value["destination"]
      destination_type = worker_egress_iterator.value["destination_type"]
      protocol         = worker_egress_iterator.value["protocol"] == "all" ? "all" : tonumber(worker_egress_iterator.value["protocol"])
      stateless        = tobool(worker_egress_iterator.value["stateless"])

      dynamic "tcp_options" {
        for_each = tonumber(worker_egress_iterator.value["port"]) == -1 ? [] : list(1)

        content {
          min = tonumber(worker_egress_iterator.value["port"])
          max = tonumber(worker_egress_iterator.value["port"])
        }
      }
    }
  }

  egress_security_rules {
    description = "Allow all outbound traffic to the internet. Required for getting container images or using external services"
    destination = local.anywhere
    protocol    = local.all_protocols
    stateless   = false
  }

  egress_security_rules {
    # leave this for now
    # investigate the list of ports required for oracle services (atp, adw, object storage and streaming and add these to locals) 

    description      = "allow stateful egress to oracle services network through the service gateway"
    destination      = lookup(data.oci_core_services.all_oci_services.services[0], "cidr_block")
    destination_type = "SERVICE_CIDR_BLOCK"
    protocol         = local.all_protocols
    stateless        = false
  }

  dynamic "ingress_security_rules" {
    iterator = worker_iterator
    for_each = [local.worker_subnet]

    content {
      description = "allow stateful ingress for all traffic between nodes on the worker subnet"
      protocol    = local.all_protocols
      source      = worker_iterator.value
      stateless   = false
    }
  }

  dynamic "ingress_security_rules" {
    for_each = var.oke_network_worker.allow_worker_ssh_access == true ? list(1) : []

    content {
      description = "allow stateful ingress that allows ssh access to the worker nodes from the bastion host"
      protocol    = local.tcp_protocol
      source      = local.bastion_subnet
      stateless   = false

      tcp_options {
        max = local.ssh_port
        min = local.ssh_port
      }
    }
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to ingress_security_rules,
      # because Kubernetes will dynamically add new ones based on
      # LoadBalancer requirements
      ingress_security_rules,
    ]
  }
  count = var.oke_network_worker.worker_mode == "private" ? 1 : 0
}

# internal load balancer security checklist
resource "oci_core_security_list" "int_lb_seclist" {
  compartment_id = var.compartment_id
  display_name   = var.label_prefix == "none" ? "int-lb" : "${var.label_prefix}-int-lb"
  vcn_id         = var.oke_network_vcn.vcn_id

  egress_security_rules {
    description = "allow stateful egress to workers. required for NodePorts and load balancer http/tcp health checks"
    protocol    = local.all_protocols
    destination = local.worker_subnet
    stateless   = false
  }

  ingress_security_rules {
    description = "allow ingress only from the public lb subnet"
    protocol    = local.tcp_protocol
    source      = var.oke_network_vcn.vcn_cidr
    stateless   = false
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to egress_security_rules,
      # because Kubernetes will dynamically add new ones based on
      # LoadBalancer requirements
      egress_security_rules,
    ]
  }
  count = var.lb_subnet_type == "internal" || var.lb_subnet_type == "both" ? 1 : 0
}

# public load balancer security checklist
resource "oci_core_security_list" "pub_lb_seclist_wo_waf" {
  compartment_id = var.compartment_id
  display_name   = var.label_prefix == "none" ? "pub-lb" : "${var.label_prefix}-pub-lb"
  vcn_id         = var.oke_network_vcn.vcn_id

  egress_security_rules {
    description = "allow stateful egress to workers. required for NodePorts and load balancer http/tcp health checks"
    protocol    = local.all_protocols
    destination = local.worker_subnet
    stateless   = false
  }

  dynamic "egress_security_rules" {
    iterator = dual_lb_iterator
    for_each = var.lb_subnet_type == "both" ? list(1) : []

    content {
      description = "allow egress from public load balancer to private load balancer"
      protocol    = local.all_protocols
      destination = local.int_lb_subnet
      stateless   = false
    }
  }  

  dynamic "ingress_security_rules" {
    iterator = pub_lb_ingress_iterator
    for_each = var.public_lb_ports

    content {
      description = "allow public ingress from anywhere on specified ports"
      protocol    = local.tcp_protocol
      source      = local.anywhere
      tcp_options {
        min = pub_lb_ingress_iterator.value
        max = pub_lb_ingress_iterator.value
      }
      stateless   = false
    }
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to egress_security_rules,
      # because Kubernetes will dynamically add new ones based on
      # LoadBalancer requirements
      egress_security_rules,
    ]
  }
  count = ((var.lb_subnet_type == "public" || var.lb_subnet_type == "both") && var.waf_enabled == false) ? 1 : 0
}

resource "oci_core_security_list" "pub_lb_seclist_with_waf" {
  compartment_id = var.compartment_id
  display_name   = var.label_prefix == "none" ? "pub-lb" : "${var.label_prefix}-pub-lb"
  vcn_id         = var.oke_network_vcn.vcn_id

  egress_security_rules {
    description = "allow stateful egress to workers. required for NodePorts and load balancer http/tcp health checks"
    protocol    = local.all_protocols
    destination = local.worker_subnet
    stateless   = false
  }

  dynamic "egress_security_rules" {
    iterator = dual_lb_iterator
    for_each = var.lb_subnet_type == "both" ? list(1) : []

    content {
      description = "allow egress from public load balancer to private load balancer"
      protocol    = local.all_protocols
      destination = local.int_lb_subnet
      stateless   = false
    }
  }  

  dynamic "ingress_security_rules" {
    iterator = waf_iterator
    for_each = local.waf_cidr_blocks

    content {
      description = "allow public ingress only from WAF CIDR blocks"
      protocol    = local.tcp_protocol
      source      = waf_iterator.value
      stateless   = false
    }
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to egress_security_rules,
      # because Kubernetes will dynamically add new ones based on
      # LoadBalancer requirements
      egress_security_rules,
    ]
  }
  count = ((var.lb_subnet_type == "public" || var.lb_subnet_type == "both") && var.waf_enabled == true) ? 1 : 0
}

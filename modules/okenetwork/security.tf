# Copyright 2017, 2021 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# control plane security list
resource "oci_core_security_list" "control_plane_seclist" {
  compartment_id = var.compartment_id
  display_name   = var.label_prefix == "none" ? "control-plane" : "${var.label_prefix}-control-plane"
  vcn_id         = var.vcn_id

  dynamic "egress_security_rules" {
    iterator = cp_egress_iterator
    for_each = local.cp_egress

    content {
      description      = cp_egress_iterator.value["description"]
      destination      = cp_egress_iterator.value["destination"]
      destination_type = cp_egress_iterator.value["destination_type"]
      protocol         = cp_egress_iterator.value["protocol"]
      stateless        = cp_egress_iterator.value["stateless"]

      dynamic "tcp_options" {
        for_each = cp_egress_iterator.value["protocol"] == local.tcp_protocol && cp_egress_iterator.value["port"] != -1 ? [1] : []

        content {
          min = cp_egress_iterator.value["port"]
          max = cp_egress_iterator.value["port"]
        }
      }

      dynamic "icmp_options" {
        for_each = cp_egress_iterator.value["protocol"] == local.icmp_protocol ? [1] : []

        content {
          type = 3
          code = 4
        }
      }
    }
  }

  dynamic "ingress_security_rules" {
    iterator = cp_ingress_iterator
    for_each = local.cp_ingress

    content {
      description = cp_ingress_iterator.value["description"]
      protocol    = cp_ingress_iterator.value["protocol"]
      source      = cp_ingress_iterator.value["source"]
      stateless   = cp_ingress_iterator.value["stateless"]

      dynamic "tcp_options" {
        for_each = cp_ingress_iterator.value["protocol"] == local.tcp_protocol && cp_ingress_iterator.value["port"] != -1 ? [1] : []

        content {
          min = cp_ingress_iterator.value["port"]
          max = cp_ingress_iterator.value["port"]
        }
      }

      dynamic "icmp_options" {
        for_each = cp_ingress_iterator.value["protocol"] == local.icmp_protocol ? [1] : []

        content {
          type = 3
          code = 4
        }
      }
    }
  }

  dynamic "ingress_security_rules" {
    iterator = cp_access_iterator
    for_each = var.control_plane_access_source

    content {
      description = "Allow external access to control plane API endpoint communication"
      protocol    = local.tcp_protocol
      source      = cp_access_iterator.value
      stateless   = false

      tcp_options {
        min = 6443
        max = 6443
      }

      icmp_options {
        type = 3
        code = 4
      }
    }
  }

  lifecycle {
    ignore_changes = [
      egress_security_rules, ingress_security_rules
    ]
  }
}

# workers security list
resource "oci_core_security_list" "workers_seclist" {
  compartment_id = var.compartment_id
  display_name   = var.label_prefix == "none" ? "workers" : "${var.label_prefix}-workers"
  vcn_id         = var.vcn_id

  dynamic "egress_security_rules" {
    iterator = workers_egress_iterator
    for_each = local.workers_egress

    content {
      description      = workers_egress_iterator.value["description"]
      destination      = workers_egress_iterator.value["destination"]
      destination_type = workers_egress_iterator.value["destination_type"]
      protocol         = workers_egress_iterator.value["protocol"]
      stateless        = workers_egress_iterator.value["stateless"]

      dynamic "tcp_options" {
        for_each = workers_egress_iterator.value["protocol"] == local.tcp_protocol && workers_egress_iterator.value["port"] != -1 ? [1] : []

        content {
          min = workers_egress_iterator.value["port"]
          max = workers_egress_iterator.value["port"]
        }
      }

      dynamic "icmp_options" {
        for_each = workers_egress_iterator.value["protocol"] == local.icmp_protocol ? [1] : []

        content {
          type = 3
          code = 4
        }
      }
    }
  }

  dynamic "ingress_security_rules" {
    iterator = workers_ingress_iterator
    for_each = local.workers_ingress

    content {
      description = workers_ingress_iterator.value["description"]
      protocol    = workers_ingress_iterator.value["protocol"]
      source      = workers_ingress_iterator.value["source"]
      stateless   = workers_ingress_iterator.value["stateless"]

      dynamic "tcp_options" {
        for_each = workers_ingress_iterator.value["protocol"] == local.tcp_protocol && workers_ingress_iterator.value["port"] != -1 ? [1] : []

        content {
          min = workers_ingress_iterator.value["port"]
          max = workers_ingress_iterator.value["port"]
        }
      }

      dynamic "icmp_options" {
        for_each = workers_ingress_iterator.value["protocol"] == local.icmp_protocol ? [1] : []

        content {
          type = 3
          code = 4
        }
      }
    }
  }

  # NodePort access - TCP
  dynamic "ingress_security_rules" {
    for_each = var.allow_node_port_access == true ? [1] : []

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

  # NodePort access - UDP
  dynamic "ingress_security_rules" {
    for_each = var.allow_node_port_access == true ? [1] : []

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

  # ssh access
  dynamic "ingress_security_rules" {
    for_each = var.allow_worker_ssh_access == true ? [1] : []

    content {
      description = "allow ssh access to worker nodes through bastion host"
      protocol    = local.tcp_protocol
      source      = local.bastion_subnet
      stateless   = false

      tcp_options {
        max = local.ssh_port
        min = local.ssh_port
      }
    }    
  }

  dynamic "ingress_security_rules" {
    for_each = var.allow_worker_ssh_access == true ? [1] : []

    content {
      description = "allow ssh access to worker nodes from operator"
      protocol    = local.tcp_protocol
      source      = local.operator_subnet
      stateless   = false

      tcp_options {
        max = local.ssh_port
        min = local.ssh_port
      }
    }    
  }

  lifecycle {
    ignore_changes = [
      egress_security_rules, ingress_security_rules
    ]
  }
}

# internal load balancer security checklist
resource "oci_core_security_list" "int_lb_seclist" {
  compartment_id = var.compartment_id
  display_name   = var.label_prefix == "none" ? "int-lb" : "${var.label_prefix}-int-lb"
  vcn_id         = var.vcn_id

  egress_security_rules {
    description = "allow stateful egress to workers. required for NodePorts and load balancer http/tcp health checks"
    protocol    = local.all_protocols
    destination = local.workers_subnet
    stateless   = false
  }

  ingress_security_rules {
    description = "allow ingress only from the public lb subnet"
    protocol    = local.tcp_protocol
    source      = var.vcn_cidr
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
  count = var.lb_type == "internal" || var.lb_type == "both" ? 1 : 0
}

resource "oci_core_security_list" "pub_lb_seclist" {
  compartment_id = var.compartment_id
  display_name   = var.label_prefix == "none" ? "pub-lb" : "${var.label_prefix}-pub-lb"
  vcn_id         = var.vcn_id

  egress_security_rules {
    description = "allow stateful egress to workers. required for NodePorts and load balancer http/tcp health checks"
    protocol    = local.all_protocols
    destination = local.workers_subnet
    stateless   = false
  }

  dynamic "egress_security_rules" {
    iterator = dual_lb_iterator
    for_each = var.lb_type == "both" ? [1] : []

    content {
      description = "allow egress from public load balancer to private load balancer"
      protocol    = local.all_protocols
      destination = local.int_lb_subnet
      stateless   = false
    }
  }

  # allow only from WAF
  dynamic "ingress_security_rules" {
    iterator = waf_iterator
    for_each = var.enable_waf == true ? data.oci_waas_edge_subnets.waf_cidr_blocks[0].edge_subnets : []

    content {
      description = "allow public ingress only from WAF CIDR blocks"
      protocol    = local.tcp_protocol
      source      = waf_iterator.value.cidr
      stateless   = false
    }
  }

  # restrict by ports only
  dynamic "ingress_security_rules" {
    iterator = pub_lb_ingress_iterator
    for_each = var.enable_waf == false ? var.public_lb_ports : []

    content {
      description = "allow public ingress from anywhere on specified ports"
      protocol    = local.tcp_protocol
      source      = local.anywhere
      tcp_options {
        min = pub_lb_ingress_iterator.value
        max = pub_lb_ingress_iterator.value
      }
      stateless = false
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
  count = (var.lb_type == "public" || var.lb_type == "both") ? 1 : 0
}

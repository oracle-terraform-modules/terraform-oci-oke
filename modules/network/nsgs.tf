# Copyright 2017, 2021, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# control plane nsg and rules
resource "oci_core_network_security_group" "cp" {
  compartment_id = var.compartment_id
  display_name   = var.label_prefix == "none" ? "control-plane" : "${var.label_prefix}-control-plane"
  vcn_id         = var.vcn_id
}

resource "oci_core_network_security_group_security_rule" "cp_egress" {
  network_security_group_id = oci_core_network_security_group.cp.id
  description               = local.cp_egress[count.index].description
  destination               = local.cp_egress[count.index].destination
  destination_type          = local.cp_egress[count.index].destination_type
  direction                 = "EGRESS"
  protocol                  = local.cp_egress[count.index].protocol

  stateless = false

  dynamic "tcp_options" {
    for_each = local.cp_egress[count.index].protocol == local.tcp_protocol && local.cp_egress[count.index].port != -1 ? [1] : []
    content {
      destination_port_range {
        min = local.cp_egress[count.index].port
        max = local.cp_egress[count.index].port
      }
    }
  }

  dynamic "icmp_options" {
    for_each = local.cp_egress[count.index].protocol == local.icmp_protocol ? [1] : []
    content {
      type = 3
      code = 4
    }
  }

  count = length(local.cp_egress)

  lifecycle {
    ignore_changes = [destination, destination_type, direction, protocol, tcp_options]
  }
}

resource "oci_core_network_security_group_security_rule" "cp_ingress" {
  network_security_group_id = oci_core_network_security_group.cp.id
  description               = local.cp_ingress[count.index].description
  direction                 = "INGRESS"
  protocol                  = local.cp_ingress[count.index].protocol
  source                    = local.cp_ingress[count.index].source
  source_type               = local.cp_ingress[count.index].source_type

  stateless = false

  dynamic "tcp_options" {
    for_each = local.cp_ingress[count.index].protocol == local.tcp_protocol ? [1] : []
    content {
      destination_port_range {
        min = local.cp_ingress[count.index].port
        max = local.cp_ingress[count.index].port
      }
    }
  }

  dynamic "icmp_options" {
    for_each = local.cp_ingress[count.index].protocol == local.icmp_protocol ? [1] : []
    content {
      type = 3
      code = 4
    }
  }

  count = length(local.cp_ingress)

  lifecycle {
    ignore_changes = [source, source_type, direction, protocol, tcp_options]
  }
}

# workers nsg and rules
resource "oci_core_network_security_group" "workers" {
  compartment_id = var.compartment_id
  display_name   = var.label_prefix == "none" ? "workers" : "${var.label_prefix}-workers"
  vcn_id         = var.vcn_id
}

resource "oci_core_network_security_group_security_rule" "workers_egress" {
  network_security_group_id = oci_core_network_security_group.workers.id
  description               = local.workers_egress[count.index].description
  destination               = local.workers_egress[count.index].destination
  destination_type          = local.workers_egress[count.index].destination_type
  direction                 = "EGRESS"
  protocol                  = local.workers_egress[count.index].protocol

  stateless = false

  dynamic "tcp_options" {
    for_each = local.workers_egress[count.index].protocol == local.tcp_protocol && local.workers_egress[count.index].port != -1 ? [1] : []
    content {
      destination_port_range {
        min = local.workers_egress[count.index].port
        max = local.workers_egress[count.index].port
      }
    }
  }

  dynamic "icmp_options" {
    for_each = local.workers_egress[count.index].protocol == local.icmp_protocol ? [1] : []
    content {
      type = 3
      code = 4
    }
  }

  count = length(local.workers_egress)

  lifecycle {
    ignore_changes = [destination, destination_type, direction, protocol, tcp_options]
  }
}

resource "oci_core_network_security_group_security_rule" "workers_ingress" {
  network_security_group_id = oci_core_network_security_group.workers.id
  description               = local.workers_ingress[count.index].description
  direction                 = "INGRESS"
  protocol                  = local.workers_ingress[count.index].protocol
  source                    = local.workers_ingress[count.index].source
  source_type               = local.workers_ingress[count.index].source_type

  stateless = false

  dynamic "tcp_options" {
    for_each = local.workers_ingress[count.index].protocol == local.tcp_protocol && local.workers_ingress[count.index].port != -1 ? [1] : []
    content {
      destination_port_range {
        min = local.workers_ingress[count.index].port
        max = local.workers_ingress[count.index].port
      }
    }
  }

  dynamic "icmp_options" {
    for_each = local.workers_ingress[count.index].protocol == local.icmp_protocol ? [1] : []
    content {
      type = 3
      code = 4
    }
  }

  count = length(local.workers_ingress)

  lifecycle {
    ignore_changes = [source, source_type, direction, protocol, tcp_options]
  }
}

# internal lb nsg and rules
resource "oci_core_network_security_group" "int_lb" {
  compartment_id = var.compartment_id
  display_name   = var.label_prefix == "none" ? "int-lb" : "${var.label_prefix}-int-lb"
  vcn_id         = var.vcn_id
}

resource "oci_core_network_security_group_security_rule" "int_lb_egress" {
  network_security_group_id = oci_core_network_security_group.int_lb.id
  description               = local.int_lb_egress[count.index].description
  destination               = local.int_lb_egress[count.index].destination
  destination_type          = local.int_lb_egress[count.index].destination_type
  direction                 = "EGRESS"
  protocol                  = local.int_lb_egress[count.index].protocol

  stateless = false
  # TODO: condition for end-to-end SSL/SSL termination
  dynamic "tcp_options" {
    for_each = local.int_lb_egress[count.index].protocol == local.tcp_protocol && local.int_lb_egress[count.index].port != -1 ? [1] : []
    content {
      destination_port_range {
        min = length(regexall("-", local.int_lb_egress[count.index].port)) > 0 ? tonumber(element(split("-", local.int_lb_egress[count.index].port), 0)) : local.int_lb_egress[count.index].port
        max = length(regexall("-", local.int_lb_egress[count.index].port)) > 0 ? tonumber(element(split("-", local.int_lb_egress[count.index].port), 1)) : local.int_lb_egress[count.index].port
      }
    }
  }

  dynamic "icmp_options" {
    for_each = local.int_lb_egress[count.index].protocol == local.icmp_protocol ? [1] : []
    content {
      type = 3
      code = 4
    }
  }

  count = length(local.int_lb_egress)

  lifecycle {
    ignore_changes = [destination, destination_type, direction, protocol, tcp_options]
  }
}

resource "oci_core_network_security_group_security_rule" "int_lb_ingress" {
  network_security_group_id = oci_core_network_security_group.int_lb.id
  description               = "Allow stateful ingress from ${element(element(local.internal_lb_allowed_list_and_ports, count.index), 0)} on port ${element(element(local.internal_lb_allowed_list_and_ports, count.index), 1)}"
  direction                 = "INGRESS"
  protocol                  = local.tcp_protocol
  source                    = element(element(local.internal_lb_allowed_list_and_ports, count.index), 0)
  source_type               = "CIDR_BLOCK"

  stateless = false

  tcp_options {
    destination_port_range {
      min = length(regexall("-", element(element(local.internal_lb_allowed_list_and_ports, count.index), 1))) > 0 ? element(split("-", element(element(local.internal_lb_allowed_list_and_ports, count.index), 1)), 0) : element(element(local.internal_lb_allowed_list_and_ports, count.index), 1)
      max = length(regexall("-", element(element(local.internal_lb_allowed_list_and_ports, count.index), 1))) > 0 ? element(split("-", element(element(local.internal_lb_allowed_list_and_ports, count.index), 1)), 1) : element(element(local.internal_lb_allowed_list_and_ports, count.index), 1)
    }
  }

  icmp_options {
    type = 3
    code = 4
  }

  count = length(local.internal_lb_allowed_list_and_ports)

  lifecycle {
    ignore_changes = [source, source_type, direction, protocol, tcp_options, icmp_options]
  }
}

# public lb nsg and rules
resource "oci_core_network_security_group" "pub_lb" {
  compartment_id = var.compartment_id
  display_name   = var.label_prefix == "none" ? "pub-lb" : "${var.label_prefix}-pub-lb"
  vcn_id         = var.vcn_id
}

resource "oci_core_network_security_group_security_rule" "pub_lb_egress" {
  network_security_group_id = oci_core_network_security_group.pub_lb.id
  description               = local.pub_lb_egress[count.index].description
  destination               = local.pub_lb_egress[count.index].destination
  destination_type          = local.pub_lb_egress[count.index].destination_type
  direction                 = "EGRESS"
  protocol                  = local.pub_lb_egress[count.index].protocol

  stateless = false

  dynamic "tcp_options" {
    for_each = local.pub_lb_egress[count.index].protocol == local.tcp_protocol && local.pub_lb_egress[count.index].port != -1 ? [1] : []
    content {
      destination_port_range {
        min = length(regexall("-", local.pub_lb_egress[count.index].port)) > 0 ? tonumber(element(split("-", local.pub_lb_egress[count.index].port), 0)) : local.pub_lb_egress[count.index].port
        max = length(regexall("-", local.pub_lb_egress[count.index].port)) > 0 ? tonumber(element(split("-", local.pub_lb_egress[count.index].port), 1)) : local.pub_lb_egress[count.index].port
      }
    }
  }

  dynamic "icmp_options" {
    for_each = local.pub_lb_egress[count.index].protocol == local.icmp_protocol ? [1] : []
    content {
      type = 3
      code = 4
    }
  }

  count = length(local.pub_lb_egress)

  lifecycle {
    ignore_changes = [destination, destination_type, direction, protocol, tcp_options]
  }
}

resource "oci_core_network_security_group_security_rule" "pub_lb_ingress" {
  network_security_group_id = oci_core_network_security_group.pub_lb.id
  description               = "Allow stateful ingress from ${element(element(local.public_lb_allowed_list_and_ports, count.index), 0)} on port ${element(element(local.public_lb_allowed_list_and_ports, count.index), 1)}"
  direction                 = "INGRESS"
  protocol                  = local.tcp_protocol
  source                    = element(element(local.public_lb_allowed_list_and_ports, count.index), 0)
  source_type               = "CIDR_BLOCK"

  stateless = false

  tcp_options {
    destination_port_range {
      min = length(regexall("-", element(element(local.public_lb_allowed_list_and_ports, count.index), 1))) > 0 ? element(split("-", element(element(local.public_lb_allowed_list_and_ports, count.index), 1)), 0) : element(element(local.public_lb_allowed_list_and_ports, count.index), 1)
      max = length(regexall("-", element(element(local.public_lb_allowed_list_and_ports, count.index), 1))) > 0 ? element(split("-", element(element(local.public_lb_allowed_list_and_ports, count.index), 1)), 1) : element(element(local.public_lb_allowed_list_and_ports, count.index), 1)
    }
  }

  icmp_options {
    type = 3
    code = 4
  }

  count = length(local.public_lb_allowed_list_and_ports)

  lifecycle {
    ignore_changes = [source, source_type, direction, protocol, tcp_options, icmp_options]
  }
}

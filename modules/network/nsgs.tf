# Copyright 2017, 2021, Oracle Corporation and/or affiliates.
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
}

resource "oci_core_network_security_group_security_rule" "cp_egress_npn" {
  network_security_group_id = oci_core_network_security_group.cp.id
  description               = "Allow Kubernetes Control plane to communicate with pods"
  destination               = local.pods_subnet
  destination_type          = "CIDR_BLOCK"
  direction                 = "EGRESS"
  protocol                  = local.all_protocols

  stateless = false

  count = var.cni_type == "npn" ? 1 :0

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

}

resource "oci_core_network_security_group_security_rule" "cp_ingress_additional_cidrs" {
  network_security_group_id = oci_core_network_security_group.cp.id
  description               = "Allow additional CIDR block access to control plane. Required for kubectl/helm."
  direction                 = "INGRESS"
  protocol                  = local.tcp_protocol
  source                    = element(var.control_plane_allowed_cidrs, count.index)
  source_type               = "CIDR_BLOCK"

  stateless = false

  tcp_options {
    destination_port_range {
      min = 6443
      max = 6443
    }
  }

  icmp_options {
    type = 3
    code = 4
  }

  count = length(var.control_plane_allowed_cidrs)

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
}

resource "oci_core_network_security_group_security_rule" "workers_egress_npn" {
  network_security_group_id = oci_core_network_security_group.workers.id
  description               = "Allow worker nodes access to pods"
  destination               = local.pods_subnet
  destination_type          = "CIDR_BLOCK"
  direction                 = "EGRESS"
  protocol                  = local.all_protocols

  stateless = false

  count = var.cni_type == "npn" ? 1: 0
}

# add this rule separately so it can be controlled independently
resource "oci_core_network_security_group_security_rule" "workers_egress_internet" {
  network_security_group_id = oci_core_network_security_group.workers.id
  description               = "Allow worker nodes access to Internet. Required for getting container images or using external services"
  destination               = local.anywhere
  destination_type          = "CIDR_BLOCK"
  direction                 = "EGRESS"
  protocol                  = local.tcp_protocol

  stateless = false

  count = var.allow_worker_internet_access == true ? 1 : 0

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

}

# add the next 4 rules separately so it can be controlled independently based on which lbs are created
resource "oci_core_network_security_group_security_rule" "workers_ingress_from_int_lb" {
  network_security_group_id = oci_core_network_security_group.workers.id
  description               = "Allow internal load balancers traffic to workers"
  direction                 = "INGRESS"
  protocol                  = local.tcp_protocol
  source                    = local.int_lb_subnet
  source_type               = "CIDR_BLOCK"

  stateless = false

  tcp_options {
    destination_port_range {
      min = local.node_port_min
      max = local.node_port_max
    }
  }

  count = var.load_balancers == "internal" || var.load_balancers == "both" ? 1 : 0

}

resource "oci_core_network_security_group_security_rule" "workers_healthcheck_ingress_from_int_lb" {
  network_security_group_id = oci_core_network_security_group.workers.id
  description               = "Allow internal load balancers health check to workers"
  direction                 = "INGRESS"
  protocol                  = local.tcp_protocol
  source                    = local.int_lb_subnet
  source_type               = "CIDR_BLOCK"

  stateless = false

  tcp_options {
    destination_port_range {
      min = local.health_check_port
      max = local.health_check_port
    }
  }

  count = var.load_balancers == "internal" || var.load_balancers == "both" ? 1 : 0

}

resource "oci_core_network_security_group_security_rule" "workers_ingress_from_pub_lb" {
  network_security_group_id = oci_core_network_security_group.workers.id
  description               = "Allow public load balancers traffic to workers"
  direction                 = "INGRESS"
  protocol                  = local.tcp_protocol
  source                    = local.pub_lb_subnet
  source_type               = "CIDR_BLOCK"

  stateless = false

  tcp_options {
    destination_port_range {
      min = local.node_port_min
      max = local.node_port_max
    }
  }

  count = var.load_balancers == "public" || var.load_balancers == "both" ? 1 : 0

}

resource "oci_core_network_security_group_security_rule" "workers_healthcheck_ingress_from_pub_lb" {
  network_security_group_id = oci_core_network_security_group.workers.id
  description               = "Allow public load balancers health check to workers"
  direction                 = "INGRESS"
  protocol                  = local.tcp_protocol
  source                    = local.pub_lb_subnet
  source_type               = "CIDR_BLOCK"

  stateless = false

  tcp_options {
    destination_port_range {
      min = local.health_check_port
      max = local.health_check_port
    }
  }

  count = var.load_balancers == "public" || var.load_balancers == "both" ? 1 : 0

}

resource "oci_core_network_security_group_security_rule" "workers_ingress_npn" {
  network_security_group_id = oci_core_network_security_group.workers.id
  description               = "Allow cross-node pod communication when using NodePorts or hostNetwork: true"
  direction                 = "INGRESS"
  protocol                  = local.all_protocols
  source                    = local.pods_subnet
  source_type               = "CIDR_BLOCK"
  stateless                 = false
  count                     = var.cni_type == "npn" ? 1 : 0
}

resource "oci_core_network_security_group_security_rule" "workers_ssh_ingress_from_bastion" {
  network_security_group_id = oci_core_network_security_group.workers.id
  description               = "Allow ssh access to workers via Bastion host"
  direction                 = "INGRESS"
  protocol                  = local.tcp_protocol
  source                    = local.bastion_subnet
  source_type               = "CIDR_BLOCK"

  stateless = false

  tcp_options {
    destination_port_range {
      min = local.ssh_port
      max = local.ssh_port
    }
  }

  count = var.allow_worker_ssh_access == true ? 1 : 0

}

# pod nsg and rules
resource "oci_core_network_security_group" "pods" {
  compartment_id = var.compartment_id
  display_name   = var.label_prefix == "none" ? "pods" : "${var.label_prefix}-pods"
  vcn_id         = var.vcn_id
  count          = var.cni_type == "npn" ? 1 : 0
}

resource "oci_core_network_security_group_security_rule" "pods_egress" {
  network_security_group_id = oci_core_network_security_group.pods[0].id
  description               = local.pods_egress[count.index].description
  destination               = local.pods_egress[count.index].destination
  destination_type          = local.pods_egress[count.index].destination_type
  direction                 = "EGRESS"
  protocol                  = local.pods_egress[count.index].protocol

  stateless = false

  dynamic "tcp_options" {
    for_each = local.pods_egress[count.index].protocol == local.tcp_protocol && local.pods_egress[count.index].port != -1 ? [1] : []
    content {
      destination_port_range {
        min = local.pods_egress[count.index].port
        max = local.pods_egress[count.index].port
      }
    }
  }

  dynamic "icmp_options" {
    for_each = local.pods_egress[count.index].protocol == local.icmp_protocol ? [1] : []
    content {
      type = 3
      code = 4
    }
  }

  count = var.cni_type =="npn" ? length(local.pods_egress) : 0
}

resource "oci_core_network_security_group_security_rule" "pods_ingress" {
  network_security_group_id = oci_core_network_security_group.pods[0].id
  description               = local.pods_ingress[count.index].description
  source                    = local.pods_ingress[count.index].source
  source_type               = local.pods_ingress[count.index].source_type
  protocol                  = local.pods_ingress[count.index].protocol
  direction                 = "INGRESS"
  stateless                 = false
  count                     = var.cni_type =="npn" ? length(local.pods_ingress) : 0
}

# add this rule separately so it can be controlled independently
resource "oci_core_network_security_group_security_rule" "pods_egress_internet" {
  network_security_group_id = oci_core_network_security_group.pods[0].id
  description               = "Allow pods access to Internet"
  destination               = local.anywhere
  destination_type          = "CIDR_BLOCK"
  direction                 = "EGRESS"
  protocol                  = local.all_protocols

  stateless = false
  count = (var.cni_type =="npn" && var.allow_pod_internet_access == true) ? 1 : 0

}

# internal lb nsg and rules
resource "oci_core_network_security_group" "int_lb" {
  compartment_id = var.compartment_id
  display_name   = var.label_prefix == "none" ? "int-lb" : "${var.label_prefix}-int-lb"
  vcn_id         = var.vcn_id

  count = var.load_balancers == "internal" || var.load_balancers == "both" ? 1 : 0
}

resource "oci_core_network_security_group_security_rule" "int_lb_egress" {
  network_security_group_id = oci_core_network_security_group.int_lb[0].id
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

  count = var.load_balancers == "internal" || var.load_balancers == "both" ? length(local.int_lb_egress) : 0
}

resource "oci_core_network_security_group_security_rule" "int_lb_ingress" {
  network_security_group_id = oci_core_network_security_group.int_lb[0].id
  description               = "Allow stateful ingress from ${element(element(local.internal_lb_allowed_cidrs_and_ports, count.index), 0)} on port ${element(element(local.internal_lb_allowed_cidrs_and_ports, count.index), 1)}"
  direction                 = "INGRESS"
  protocol                  = local.tcp_protocol
  source                    = element(element(local.internal_lb_allowed_cidrs_and_ports, count.index), 0)
  source_type               = "CIDR_BLOCK"

  stateless = false

  tcp_options {
    destination_port_range {
      min = length(regexall("-", element(element(local.internal_lb_allowed_cidrs_and_ports, count.index), 1))) > 0 ? element(split("-", element(element(local.internal_lb_allowed_cidrs_and_ports, count.index), 1)), 0) : element(element(local.internal_lb_allowed_cidrs_and_ports, count.index), 1)
      max = length(regexall("-", element(element(local.internal_lb_allowed_cidrs_and_ports, count.index), 1))) > 0 ? element(split("-", element(element(local.internal_lb_allowed_cidrs_and_ports, count.index), 1)), 1) : element(element(local.internal_lb_allowed_cidrs_and_ports, count.index), 1)
    }
  }

  count = var.load_balancers == "internal" || var.load_balancers == "both" ? length(local.internal_lb_allowed_cidrs_and_ports) : 0
}

# public lb nsg and rules
resource "oci_core_network_security_group" "pub_lb" {
  compartment_id = var.compartment_id
  display_name   = var.label_prefix == "none" ? "pub-lb" : "${var.label_prefix}-pub-lb"
  vcn_id         = var.vcn_id

  count = var.load_balancers == "public" || var.load_balancers == "both" ? 1 : 0
}

resource "oci_core_network_security_group_security_rule" "pub_lb_egress" {
  network_security_group_id = oci_core_network_security_group.pub_lb[0].id
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

  count = var.load_balancers == "public" || var.load_balancers == "both" ? length(local.pub_lb_egress) : 0
}

resource "oci_core_network_security_group_security_rule" "pub_lb_egress_health_check_to_workers" {
  network_security_group_id = oci_core_network_security_group.pub_lb[0].id
  description               = "Allow public load balancer health checks to workers"
  destination               = local.workers_subnet
  destination_type          = "CIDR_BLOCK"
  direction                 = "EGRESS"
  protocol                  = local.tcp_protocol

  stateless = false

  tcp_options {
    destination_port_range {
      min = local.health_check_port
      max = local.health_check_port
    }
  }

  count = var.load_balancers == "public" || var.load_balancers == "both" ? 1 : 0
}

resource "oci_core_network_security_group_security_rule" "pub_lb_egress_health_check_to_int_lb" {
  network_security_group_id = oci_core_network_security_group.pub_lb[0].id
  description               = "Allow public load balancer health checks to internal load balancers"
  destination               = local.int_lb_subnet
  destination_type          = "CIDR_BLOCK"
  direction                 = "EGRESS"
  protocol                  = local.tcp_protocol

  stateless = false

  tcp_options {
    destination_port_range {
      min = length(regexall("-", element(var.internal_lb_allowed_ports, count.index))) > 0 ? tonumber(element(split("-", element(var.internal_lb_allowed_ports, count.index)), 0)) : element(var.internal_lb_allowed_ports, count.index)
      max = length(regexall("-", element(var.internal_lb_allowed_ports, count.index))) > 0 ? tonumber(element(split("-", element(var.internal_lb_allowed_ports, count.index)), 1)) : element(var.internal_lb_allowed_ports, count.index)
    }
  }

  count = var.load_balancers == "both" ? length(var.internal_lb_allowed_ports) : 0
}

resource "oci_core_network_security_group_security_rule" "pub_lb_ingress" {
  network_security_group_id = oci_core_network_security_group.pub_lb[0].id
  description               = "Allow stateful ingress from ${element(element(local.public_lb_allowed_cidrs_and_ports, count.index), 0)} on port ${element(element(local.public_lb_allowed_cidrs_and_ports, count.index), 1)}"
  direction                 = "INGRESS"
  protocol                  = local.tcp_protocol
  source                    = element(element(local.public_lb_allowed_cidrs_and_ports, count.index), 0)
  source_type               = "CIDR_BLOCK"

  stateless = false

  tcp_options {
    destination_port_range {
      min = length(regexall("-", element(element(local.public_lb_allowed_cidrs_and_ports, count.index), 1))) > 0 ? element(split("-", element(element(local.public_lb_allowed_cidrs_and_ports, count.index), 1)), 0) : element(element(local.public_lb_allowed_cidrs_and_ports, count.index), 1)
      max = length(regexall("-", element(element(local.public_lb_allowed_cidrs_and_ports, count.index), 1))) > 0 ? element(split("-", element(element(local.public_lb_allowed_cidrs_and_ports, count.index), 1)), 1) : element(element(local.public_lb_allowed_cidrs_and_ports, count.index), 1)
    }
  }

  count = var.load_balancers == "public" || var.load_balancers == "both" ? length(local.public_lb_allowed_cidrs_and_ports) : 0
}

# waf lb nsg and rules
resource "oci_core_network_security_group" "waf" {
  compartment_id = var.compartment_id
  display_name   = var.label_prefix == "none" ? "waf" : "${var.label_prefix}-waf"
  vcn_id         = var.vcn_id

  count = var.enable_waf == true ? 1 : 0
}

resource "oci_core_network_security_group_security_rule" "waf_ingress" {
  for_each                  = var.enable_waf == true ? toset(local.waf_cidr_list) : toset([])
  network_security_group_id = oci_core_network_security_group.waf[0].id
  description               = "Allow stateful ingress from WAF"
  direction                 = "INGRESS"
  protocol                  = local.tcp_protocol
  source                    = each.key
  source_type               = "CIDR_BLOCK"

  stateless = false

  tcp_options {
    destination_port_range {
      min = 443
      max = 443
    }
  }

}

## fss : instance network security group rules

resource "oci_core_network_security_group_security_rule" "fss_inst_ingress" {
  network_security_group_id = oci_core_network_security_group.workers.id
  direction                 = "INGRESS"
  protocol                  = local.fss_inst_ingress[count.index].protocol
  source                    = local.fss_inst_ingress[count.index].source
  source_type               = local.fss_inst_ingress[count.index].source_type
  description               = local.fss_inst_ingress[count.index].description
  stateless                 = false

  dynamic "tcp_options" {
    for_each = local.fss_inst_ingress[count.index].protocol == local.tcp_protocol ? [1] : []
    content {
      source_port_range {
        min = local.fss_inst_ingress[count.index].port
        max = local.fss_inst_ingress[count.index].port
      }
    }
  }

  dynamic "udp_options" {
    for_each = local.fss_inst_ingress[count.index].protocol == local.udp_protocol ? [1] : []
    content {
      source_port_range {
        min = local.fss_inst_ingress[count.index].port
        max = local.fss_inst_ingress[count.index].port
      }
    }
  }

  count = var.create_fss ? length(local.fss_inst_ingress) : 0
}

resource "oci_core_network_security_group_security_rule" "fss_inst_egress" {
  network_security_group_id = oci_core_network_security_group.workers.id
  direction                 = "EGRESS"
  protocol                  = local.fss_inst_egress[count.index].protocol
  destination               = local.fss_inst_egress[count.index].destination
  destination_type          = local.fss_inst_egress[count.index].destination_type
  description               = local.fss_inst_egress[count.index].description
  stateless                 = false

  dynamic "tcp_options" {
    for_each = local.fss_inst_egress[count.index].protocol == local.tcp_protocol ? [1] : []
    content {
      destination_port_range {
        min = local.fss_inst_egress[count.index].port
        max = local.fss_inst_egress[count.index].port
      }
    }
  }

  dynamic "udp_options" {
    for_each = local.fss_inst_egress[count.index].protocol == local.udp_protocol ? [1] : []
    content {
      destination_port_range {
        min = local.fss_inst_egress[count.index].port
        max = local.fss_inst_egress[count.index].port
      }
    }
  }

  count = var.create_fss ? length(local.fss_inst_egress) : 0
}

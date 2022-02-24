# fss mount point and instance security group and rule definition
## fss mount point security group and rules
resource "oci_core_network_security_group" "fss_mt" {
  compartment_id = var.compartment_id
  display_name   = var.label_prefix == "none" ? "fss-mt" : "${var.label_prefix}-fss-mt"
  vcn_id         = var.vcn_id

}

resource "oci_core_network_security_group_security_rule" "fss_mt_ingress" {
  network_security_group_id = oci_core_network_security_group.fss_mt.id
  direction                 = "INGRESS"
  protocol                  = local.fss_mt_ingress[count.index].protocol
  source                    = local.fss_mt_ingress[count.index].source
  source_type               = local.fss_mt_ingress[count.index].source_type
  description               = "Allow incoming traffic for FSS Mount Target from OKE worker subnet"

  stateless = false

  dynamic "tcp_options" {
    for_each = local.fss_mt_ingress[count.index].protocol == local.tcp_protocol ? [1] : []
    content {
      destination_port_range {
        min = local.fss_mt_ingress[count.index].port
        max = local.fss_mt_ingress[count.index].port
      }
    }
  }

  dynamic "udp_options" {
    for_each = local.fss_mt_ingress[count.index].protocol == local.udp_protocol ? [1] : []
    content {
      source_port_range {
        min = local.fss_mt_ingress[count.index].port
        max = local.fss_mt_ingress[count.index].port
      }
    }
  }

  count = length(local.fss_mt_ingress)
}

resource "oci_core_network_security_group_security_rule" "fss_mt_egress" {
  network_security_group_id = oci_core_network_security_group.fss_mt.id
  direction                 = "EGRESS"
  protocol                  = local.fss_mt_egress[count.index].protocol
  destination               = local.fss_mt_egress[count.index].destination
  destination_type          = local.fss_mt_egress[count.index].destination_type
  description               = "Allow outgoing traffic from FSS Mount Target to OKE worker subnet"
  stateless                 = false

  dynamic "tcp_options" {
    for_each = local.fss_mt_egress[count.index].protocol == local.tcp_protocol ? [1] : []
    content {
      destination_port_range {
        min = local.fss_mt_egress[count.index].port
        max = local.fss_mt_egress[count.index].port
      }
    }
  }

  dynamic "udp_options" {
    for_each = local.fss_mt_egress[count.index].protocol == local.udp_protocol ? [1] : []
    content {
      source_port_range {
        min = local.fss_mt_egress[count.index].port
        max = local.fss_mt_egress[count.index].port
      }
    }
  }

  count = length(local.fss_mt_egress)
}



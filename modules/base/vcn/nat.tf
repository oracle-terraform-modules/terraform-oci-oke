# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

resource "oci_core_nat_gateway" "nat_gateway" {
  compartment_id = var.oci_base_vcn.compartment_id
  display_name   = "${var.oci_base_vcn.label_prefix}-nat-gw"
  vcn_id         = oci_core_vcn.vcn.id
  count          = var.oci_base_vcn.nat_gateway_enabled == true ? 1 : 0
}

resource "oci_core_route_table" "nat_route" {
  compartment_id = var.oci_base_vcn.compartment_id
  display_name   = "${var.oci_base_vcn.label_prefix}-nat-route"

  route_rules {
    destination       = local.anywhere
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.nat_gateway[0].id
  }

  dynamic "route_rules" {
    for_each = var.oci_base_vcn.service_gateway_enabled == true ? list(1) : []

    content {
      destination       = lookup(data.oci_core_services.all_oci_services[0].services[0], "cidr_block")
      destination_type  = "SERVICE_CIDR_BLOCK"
      network_entity_id = oci_core_service_gateway.service_gateway[0].id
    }
  }

  vcn_id = oci_core_vcn.vcn.id
  count  = var.oci_base_vcn.nat_gateway_enabled == true ? 1 : 0
}

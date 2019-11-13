# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

resource "oci_core_vcn" "vcn" {
  cidr_block     = var.oci_base_vcn.vcn_cidr
  compartment_id = var.oci_base_vcn.compartment_id
  display_name   = "${var.oci_base_vcn.label_prefix}-${var.oci_base_vcn.vcn_name}"
  dns_label      = var.oci_base_vcn.vcn_dns_label
}

resource "oci_core_internet_gateway" "ig" {
  compartment_id = var.oci_base_vcn.compartment_id
  display_name   = "${var.oci_base_vcn.label_prefix}-ig-gw"
  vcn_id         = oci_core_vcn.vcn.id
}

resource "oci_core_route_table" "ig_route" {
  compartment_id = var.oci_base_vcn.compartment_id
  display_name   = "${var.oci_base_vcn.label_prefix}-ig-route"

  route_rules {
    destination       = local.anywhere
    network_entity_id = oci_core_internet_gateway.ig.id
  }

  dynamic "route_rules" {
    for_each = (var.oci_base_vcn.create_service_gateway == true && var.oci_base_vcn.create_nat_gateway == false)  ? list(1) : []

    content {
      destination       = lookup(data.oci_core_services.all_oci_services[0].services[0], "cidr_block")
      destination_type  = "SERVICE_CIDR_BLOCK"
      network_entity_id = oci_core_service_gateway.service_gateway[0].id
    }
  }

  vcn_id = oci_core_vcn.vcn.id
}
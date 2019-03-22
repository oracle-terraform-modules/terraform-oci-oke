# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_core_nat_gateway" "nat_gateway" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_vcn.vcn.id}"
  display_name   = "${var.label_prefix}-${var.nat_gateway_name}"
  count          = "${(var.create_nat_gateway == "true") ? "1" : "0"}"
}

resource "oci_core_route_table" "nat_route" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_vcn.vcn.id}"
  display_name   = "${var.label_prefix}-nat_route"

  route_rules = [
    {
      destination       = "${local.anywhere}"
      destination_type  = "CIDR_BLOCK"
      network_entity_id = "${oci_core_nat_gateway.nat_gateway.id}"
    },
  ]

  count = "${(var.create_nat_gateway == "true") ? 1 : 0}"
}

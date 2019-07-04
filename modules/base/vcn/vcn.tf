# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

locals {
  anywhere = "0.0.0.0/0"
}

resource "oci_core_vcn" "vcn" {
  cidr_block     = var.vcn_cidr
  compartment_id = var.compartment_ocid
  display_name   = "${var.label_prefix}-${var.vcn_name}"
  dns_label      = var.vcn_dns_name
}

resource "oci_core_internet_gateway" "ig" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.label_prefix}-ig-gw"
  vcn_id         = oci_core_vcn.vcn.id
}

resource "oci_core_route_table" "ig_route" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.label_prefix}-ig-route"

  route_rules {
    destination       = local.anywhere
    network_entity_id = oci_core_internet_gateway.ig.id
  }

  vcn_id = oci_core_vcn.vcn.id
}
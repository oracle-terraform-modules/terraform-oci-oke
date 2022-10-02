# Copyright 2017, 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

data "oci_core_vcns" "vcns" {
  count = var.create_vcn == true ? 0 : 1

  compartment_id = local.compartment_id
  display_name   = var.vcn_display_name

  state = "AVAILABLE"
}

data "oci_core_route_tables" "nat" {
  count = var.create_vcn == true ? 0 : 1

  compartment_id = local.compartment_id

  display_name = var.nat_route_table_display_name
  vcn_id       = local.vcn_id

  state = "AVAILABLE"
}

data "oci_core_route_tables" "ig" {
  count = var.create_vcn == true ? 0 : 1

  compartment_id = local.compartment_id

  display_name = var.ig_route_table_display_name
  vcn_id       = local.vcn_id

  state = "AVAILABLE"
}
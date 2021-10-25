# Copyright 2017, 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "oci_core_subnet" "cp" {
  cidr_block                 = local.cp_subnet
  compartment_id             = var.compartment_id
  display_name               = var.label_prefix == "none" ? "control-plane" : "${var.label_prefix}-control-plane"
  dns_label                  = "cp"
  prohibit_public_ip_on_vnic = var.control_plane_type == "private" ? true : false
  route_table_id             = var.control_plane_type == "private" ? var.nat_route_id : var.ig_route_id
  security_list_ids          = [oci_core_security_list.control_plane_seclist.id]
  vcn_id                     = var.vcn_id
}

resource "oci_core_subnet" "workers" {
  cidr_block                 = local.workers_subnet
  compartment_id             = var.compartment_id
  display_name               = var.label_prefix == "none" ? "workers" : "${var.label_prefix}-workers"
  dns_label                  = "workers"
  prohibit_public_ip_on_vnic = var.worker_type == "private" ? true : false
  route_table_id             = var.worker_type == "private" ? var.nat_route_id : var.ig_route_id
  vcn_id                     = var.vcn_id
}

resource "oci_core_subnet" "int_lb" {
  cidr_block                 = local.int_lb_subnet
  compartment_id             = var.compartment_id
  display_name               = var.label_prefix == "none" ? "int_lb" : "${var.label_prefix}-int_lb"
  dns_label                  = "intlb"
  prohibit_public_ip_on_vnic = true
  route_table_id             = var.nat_route_id
  vcn_id                     = var.vcn_id

  count = var.load_balancers == "internal" || var.load_balancers == "both" ? 1 : 0
}

resource "oci_core_subnet" "pub_lb" {
  cidr_block                 = local.pub_lb_subnet
  compartment_id             = var.compartment_id
  display_name               = var.label_prefix == "none" ? "pub_lb" : "${var.label_prefix}-pub_lb"
  dns_label                  = "publb"
  prohibit_public_ip_on_vnic = false
  route_table_id             = var.ig_route_id
  # security_list_ids          = [oci_core_security_list.pub_lb_seclist[0].id]
  vcn_id = var.vcn_id

  count = var.load_balancers == "public" || var.load_balancers == "both" ? 1 : 0
}

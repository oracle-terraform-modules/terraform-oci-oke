# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "oci_core_subnet" "workers" {
  cidr_block                 = local.worker_subnet
  compartment_id             = var.compartment_id
  display_name               = var.label_prefix == "none" ? "workers" : "${var.label_prefix}-workers"
  dns_label                  = "workers"
  prohibit_public_ip_on_vnic = var.oke_network_worker.worker_mode == "private" ? true : false
  route_table_id             = var.oke_network_worker.worker_mode == "private" ? var.oke_network_vcn.nat_route_id : var.oke_network_vcn.ig_route_id
  security_list_ids          = var.oke_network_worker.worker_mode == "private" ? [oci_core_security_list.private_workers_seclist[0].id] : [oci_core_security_list.public_workers_seclist[0].id]
  vcn_id                     = var.oke_network_vcn.vcn_id
}

resource "oci_core_subnet" "int_lb" {
  cidr_block                 = local.int_lb_subnet
  compartment_id             = var.compartment_id
  display_name               = var.label_prefix == "none" ? "int_lb" : "${var.label_prefix}-int_lb"
  dns_label                  = "intlb"
  prohibit_public_ip_on_vnic = true
  route_table_id             = var.oke_network_vcn.nat_route_id
  security_list_ids          = [oci_core_security_list.int_lb_seclist[0].id]
  vcn_id                     = var.oke_network_vcn.vcn_id

  count = var.lb_subnet_type == "internal" || var.lb_subnet_type == "both" ? 1 : 0
}

resource "oci_core_subnet" "pub_lb" {
  cidr_block                 = local.pub_lb_subnet
  compartment_id             = var.compartment_id
  display_name               = var.label_prefix == "none" ? "pub_lb" : "${var.label_prefix}-pub_lb"
  dns_label                  = "publb"
  prohibit_public_ip_on_vnic = false
  route_table_id             = var.oke_network_vcn.ig_route_id
  security_list_ids          = var.waf_enabled == false ? [oci_core_security_list.pub_lb_seclist_wo_waf[0].id] : [oci_core_security_list.pub_lb_seclist_with_waf[0].id]
  vcn_id                     = var.oke_network_vcn.vcn_id

  count = var.lb_subnet_type == "public" || var.lb_subnet_type == "both" ? 1 : 0
}

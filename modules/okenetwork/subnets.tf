# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_core_subnet" "workers_ad1" {
  availability_domain        = element(var.oke_general.ad_names, 0)
  cidr_block                 = local.worker_subnet_ad1
  compartment_id             = var.compartment_ocid
  display_name               = "${var.oke_general.label_prefix}_workers_ad1"
  dns_label                  = "w1"
  prohibit_public_ip_on_vnic = var.oke_network_worker.worker_mode == "private" ? true : false
  route_table_id             = var.oke_network_worker.worker_mode == "private" ? var.oke_network_vcn.nat_route_id : var.oke_network_vcn.ig_route_id
  security_list_ids          = var.oke_network_worker.worker_mode == "private" ? [oci_core_security_list.private_workers_seclist[0].id] : [oci_core_security_list.public_workers_seclist[0].id]
  vcn_id                     = var.oke_network_vcn.vcn_id
}

resource "oci_core_subnet" "workers_ad2" {
  availability_domain        = length(var.oke_general.ad_names) == 3 ? element(var.oke_general.ad_names, 1) : element(var.oke_general.ad_names, 0)
  cidr_block                 = local.worker_subnet_ad2
  compartment_id             = var.compartment_ocid
  display_name               = "${var.oke_general.label_prefix}_workers_ad2"
  dns_label                  = "w2"
  prohibit_public_ip_on_vnic = var.oke_network_worker.worker_mode == "private" ? true : false
  route_table_id             = var.oke_network_worker.worker_mode == "private" ? var.oke_network_vcn.nat_route_id : var.oke_network_vcn.ig_route_id
  security_list_ids          = var.oke_network_worker.worker_mode == "private" ? [oci_core_security_list.private_workers_seclist[0].id] : [oci_core_security_list.public_workers_seclist[0].id]
  vcn_id                     = var.oke_network_vcn.vcn_id
}

resource "oci_core_subnet" "workers_ad3" {
  availability_domain        = length(var.oke_general.ad_names) == 3 ? element(var.oke_general.ad_names, 2) : element(var.oke_general.ad_names, 0)
  cidr_block                 = local.worker_subnet_ad3
  compartment_id             = var.compartment_ocid
  display_name               = "${var.oke_general.label_prefix}_workers_ad3"
  dns_label                  = "w3"
  prohibit_public_ip_on_vnic = var.oke_network_worker.worker_mode == "private" ? true : false
  route_table_id             = var.oke_network_worker.worker_mode == "private" ? var.oke_network_vcn.nat_route_id : var.oke_network_vcn.ig_route_id
  security_list_ids          = var.oke_network_worker.worker_mode == "private" ? [oci_core_security_list.private_workers_seclist[0].id] : [oci_core_security_list.public_workers_seclist[0].id]
  vcn_id                     = var.oke_network_vcn.vcn_id
}

resource "oci_core_subnet" "int_lb_ad1" {
  availability_domain        = element(var.oke_general.ad_names, 0)
  cidr_block                 = local.int_subnet_ad1
  compartment_id             = var.compartment_ocid
  display_name               = "${var.oke_general.label_prefix}_int_lb_ad1"
  dns_label                  = "intlb1"
  prohibit_public_ip_on_vnic = true
  route_table_id             = var.oke_network_vcn.ig_route_id
  security_list_ids          = [oci_core_security_list.int_lb_seclist[0].id]
  vcn_id                     = var.oke_network_vcn.vcn_id

  count = var.lb_subnet_type == "internal" || var.lb_subnet_type == "both" ? 1 : 0
}

resource "oci_core_subnet" "int_lb_ad2" {
  availability_domain        = length(var.oke_general.ad_names) == 3 ? element(var.oke_general.ad_names, 1) : element(var.oke_general.ad_names, 0)
  cidr_block                 = local.int_subnet_ad2
  compartment_id             = var.compartment_ocid
  display_name               = "${var.oke_general.label_prefix}_int_lb_ad2"
  dns_label                  = "intlb2"
  prohibit_public_ip_on_vnic = true
  route_table_id             = var.oke_network_vcn.ig_route_id
  security_list_ids          = [oci_core_security_list.int_lb_seclist[0].id]
  vcn_id                     = var.oke_network_vcn.vcn_id

  count = var.lb_subnet_type == "internal" || var.lb_subnet_type == "both" ? 1 : 0
}

resource "oci_core_subnet" "int_lb_ad3" {
  availability_domain        = length(var.oke_general.ad_names) == 3 ? element(var.oke_general.ad_names, 2) : element(var.oke_general.ad_names, 0)
  cidr_block                 = local.int_subnet_ad3
  compartment_id             = var.compartment_ocid
  display_name               = "${var.oke_general.label_prefix}_int_lb_ad3"
  dns_label                  = "intlb3"
  prohibit_public_ip_on_vnic = true
  route_table_id             = var.oke_network_vcn.ig_route_id
  security_list_ids          = [oci_core_security_list.int_lb_seclist[0].id]
  vcn_id                     = var.oke_network_vcn.vcn_id

  count = var.lb_subnet_type == "internal" || var.lb_subnet_type == "both" ? 1 : 0
}

resource "oci_core_subnet" "pub_lb_ad1" {
  availability_domain        = element(var.oke_general.ad_names, 0)
  cidr_block                 = local.pub_subnet_ad1
  compartment_id             = var.compartment_ocid
  display_name               = "${var.oke_general.label_prefix}_pub_lb_ad1"
  dns_label                  = "publb1"
  prohibit_public_ip_on_vnic = false
  route_table_id             = var.oke_network_vcn.ig_route_id
  security_list_ids          = [oci_core_security_list.pub_lb_seclist[0].id]
  vcn_id                     = var.oke_network_vcn.vcn_id

  count = var.lb_subnet_type == "public" || var.lb_subnet_type == "both" ? 1 : 0
}

resource "oci_core_subnet" "pub_lb_ad2" {
  availability_domain        = length(var.oke_general.ad_names) == 3 ? element(var.oke_general.ad_names, 1) : element(var.oke_general.ad_names, 0)
  cidr_block                 = local.pub_subnet_ad2
  compartment_id             = var.compartment_ocid
  display_name               = "${var.oke_general.label_prefix}_pub_lb_ad2"
  dns_label                  = "publb2"
  prohibit_public_ip_on_vnic = false
  route_table_id             = var.oke_network_vcn.ig_route_id
  security_list_ids          = [oci_core_security_list.pub_lb_seclist[0].id]
  vcn_id                     = var.oke_network_vcn.vcn_id

  count = var.lb_subnet_type == "public" || var.lb_subnet_type == "both" ? 1 : 0
}

resource "oci_core_subnet" "pub_lb_ad3" {
  availability_domain        = length(var.oke_general.ad_names) == 3 ? element(var.oke_general.ad_names, 2) : element(var.oke_general.ad_names, 0)
  cidr_block                 = local.pub_subnet_ad3
  compartment_id             = var.compartment_ocid
  display_name               = "${var.oke_general.label_prefix}_pub_lb_ad3"
  dns_label                  = "publb3"
  prohibit_public_ip_on_vnic = false
  route_table_id             = var.oke_network_vcn.ig_route_id
  security_list_ids          = [oci_core_security_list.pub_lb_seclist[0].id]
  vcn_id                     = var.oke_network_vcn.vcn_id

  count = var.lb_subnet_type == "public" || var.lb_subnet_type == "both" ? 1 : 0
}

# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_core_subnet" "workers_ad1" {
  availability_domain        = "${length(var.ad_names) > 1 ? element(var.ad_names, 0): element(var.ad_names, 0)}"
  cidr_block                 = "${cidrsubnet(var.vcn_cidr,var.newbits["workers"],var.subnets["workers_ad1"])}"
  display_name               = "${var.label_prefix}-workers_ad1"
  compartment_id             = "${var.compartment_ocid}"
  vcn_id                     = "${var.vcn_id}"
  route_table_id             = "${(var.worker_mode == "private") ? var.nat_route_id : var.ig_route_id}"
  security_list_ids          = ["${oci_core_security_list.workers_seclist.id}"]
  dns_label                  = "w1"
  count                      = "${(var.availability_domains["workers_ad1"] == "true") ? 1 : 0}"
  prohibit_public_ip_on_vnic = "${(var.worker_mode == "private") ? true : false}"
}

resource "oci_core_subnet" "workers_ad2" {
  availability_domain        = "${length(var.ad_names) > 1 ? element(var.ad_names, 1): element(var.ad_names, 0)}"
  cidr_block                 = "${cidrsubnet(var.vcn_cidr,var.newbits["workers"],var.subnets["workers_ad2"])}"
  display_name               = "${var.label_prefix}-workers_ad2"
  compartment_id             = "${var.compartment_ocid}"
  vcn_id                     = "${var.vcn_id}"
  route_table_id             = "${(var.worker_mode == "private") ? var.nat_route_id : var.ig_route_id}"
  security_list_ids          = ["${oci_core_security_list.workers_seclist.id}"]
  dns_label                  = "w2"
  count                      = "${(var.availability_domains["workers_ad2"] == "true") ? 1 : 0}"
  prohibit_public_ip_on_vnic = "${(var.worker_mode == "private") ? true : false}"
}

resource "oci_core_subnet" "workers_ad3" {
  availability_domain        = "${length(var.ad_names) > 1 ? element(var.ad_names, 2): element(var.ad_names, 0)}"
  cidr_block                 = "${cidrsubnet(var.vcn_cidr,var.newbits["workers"],var.subnets["workers_ad3"])}"
  display_name               = "${var.label_prefix}-workers_ad3"
  compartment_id             = "${var.compartment_ocid}"
  vcn_id                     = "${var.vcn_id}"
  route_table_id             = "${(var.worker_mode == "private") ? var.nat_route_id : var.ig_route_id}"
  security_list_ids          = ["${oci_core_security_list.workers_seclist.id}"]
  dns_label                  = "w3"
  count                      = "${(var.availability_domains["workers_ad3"] == "true") ? 1 : 0}"
  prohibit_public_ip_on_vnic = "${(var.worker_mode == "private") ? true : false}"
}

resource "oci_core_subnet" "lb_ad1" {
  availability_domain        = "${length(var.ad_names) > 1 ? element(var.ad_names, 0): element(var.ad_names, 0)}"
  cidr_block                 = "${cidrsubnet(var.vcn_cidr,var.newbits["lb"],var.subnets["lb_ad1"])}"
  display_name               = "${var.label_prefix}-lb_ad1"
  compartment_id             = "${var.compartment_ocid}"
  vcn_id                     = "${var.vcn_id}"
  route_table_id             = "${var.ig_route_id}"
  security_list_ids          = ["${oci_core_security_list.lb_seclist.id}"]
  dns_label                  = "lb1"
  count                      = "${(var.availability_domains["lb_ad1"] == "true") ? 1 : 0}"
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_subnet" "lb_ad2" {
  availability_domain        = "${length(var.ad_names) > 1 ? element(var.ad_names, 1): element(var.ad_names, 0)}"
  cidr_block                 = "${cidrsubnet(var.vcn_cidr,var.newbits["lb"],var.subnets["lb_ad2"])}"
  display_name               = "${var.label_prefix}-lb_ad2"
  compartment_id             = "${var.compartment_ocid}"
  vcn_id                     = "${var.vcn_id}"
  route_table_id             = "${var.ig_route_id}"
  security_list_ids          = ["${oci_core_security_list.lb_seclist.id}"]
  dns_label                  = "lb2"
  count                      = "${(var.availability_domains["lb_ad2"] == "true") ? 1 : 0}"
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_subnet" "lb_ad3" {
  availability_domain        = "${length(var.ad_names) > 1 ? element(var.ad_names, 2): element(var.ad_names, 0)}"
  cidr_block                 = "${cidrsubnet(var.vcn_cidr,var.newbits["lb"],var.subnets["lb_ad3"])}"
  display_name               = "${var.label_prefix}-lb_ad3"
  compartment_id             = "${var.compartment_ocid}"
  vcn_id                     = "${var.vcn_id}"
  route_table_id             = "${var.ig_route_id}"
  security_list_ids          = ["${oci_core_security_list.lb_seclist.id}"]
  dns_label                  = "lb3"
  count                      = "${(var.availability_domains["lb_ad3"] == "true") ? 1 : 0}"
  prohibit_public_ip_on_vnic = false
}

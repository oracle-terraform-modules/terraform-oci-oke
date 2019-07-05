# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

locals {
  worker_subnet_ad1 = cidrsubnet(var.vcn_cidr, var.newbits["workers"], var.subnets["workers_ad1"])
  worker_subnet_ad2 = cidrsubnet(var.vcn_cidr, var.newbits["workers"], var.subnets["workers_ad2"])
  worker_subnet_ad3 = cidrsubnet(var.vcn_cidr, var.newbits["workers"], var.subnets["workers_ad3"])
  lb_subnet_ad1     = cidrsubnet(var.vcn_cidr, var.newbits["lb"], var.subnets["lb_ad1"])
  lb_subnet_ad2     = cidrsubnet(var.vcn_cidr, var.newbits["lb"], var.subnets["lb_ad2"])
  lb_subnet_ad3     = cidrsubnet(var.vcn_cidr, var.newbits["lb"], var.subnets["lb_ad3"])
}
resource "oci_core_subnet" "workers_ad1" {
  availability_domain        = element(var.ad_names, 0)
  cidr_block                 = local.worker_subnet_ad1
  compartment_id             = var.compartment_ocid
  display_name               = "${var.label_prefix}-workers-ad1"
  dns_label                  = "w1"
  prohibit_public_ip_on_vnic = var.worker_mode == "private" ? true : false
  route_table_id             = var.worker_mode == "private" ? var.nat_route_id : var.ig_route_id
  security_list_ids          = [oci_core_security_list.workers_seclist.id]
  vcn_id                     = var.vcn_id

  count = var.availability_domains["workers_ad1"] == 1 ? 1 : 0
}

resource "oci_core_subnet" "workers_ad2" {
  availability_domain        = length(var.ad_names) == 3 ? element(var.ad_names, 1) : element(var.ad_names, 0)
  cidr_block                 = local.worker_subnet_ad2
  compartment_id             = var.compartment_ocid
  display_name               = "${var.label_prefix}-workers-ad2"
  dns_label                  = "w2"
  prohibit_public_ip_on_vnic = var.worker_mode == "private" ? true : false
  route_table_id             = var.worker_mode == "private" ? var.nat_route_id : var.ig_route_id
  security_list_ids          = [oci_core_security_list.workers_seclist.id]
  vcn_id                     = var.vcn_id

  count = var.availability_domains["workers_ad2"] == 2 ? 1 : 0
}

resource "oci_core_subnet" "workers_ad3" {
  availability_domain        = length(var.ad_names) == 3 ? element(var.ad_names, 2) : element(var.ad_names, 0)
  cidr_block                 = local.worker_subnet_ad3
  compartment_id             = var.compartment_ocid
  display_name               = "${var.label_prefix}-workers-ad3"
  dns_label                  = "w3"
  prohibit_public_ip_on_vnic = var.worker_mode == "private" ? true : false
  route_table_id             = var.worker_mode == "private" ? var.nat_route_id : var.ig_route_id
  security_list_ids          = [oci_core_security_list.workers_seclist.id]
  vcn_id                     = var.vcn_id

  count = var.availability_domains["workers_ad3"] == 3 ? 1 : 0
}

resource "oci_core_subnet" "lb_ad1" {
  availability_domain        = element(var.ad_names, 0)
  cidr_block                 = local.lb_subnet_ad1
  compartment_id             = var.compartment_ocid
  display_name               = "${var.label_prefix}-lb_ad1"
  dns_label                  = "lb1"
  prohibit_public_ip_on_vnic = false
  route_table_id             = var.ig_route_id
  security_list_ids          = [oci_core_security_list.lb_seclist.id]
  vcn_id                     = var.vcn_id

  count = var.availability_domains["lb_ad1"] == 1 ? 1 : 0
}

resource "oci_core_subnet" "lb_ad2" {
  availability_domain        = length(var.ad_names) == 3 ? element(var.ad_names, 1) : element(var.ad_names, 0)
  cidr_block                 = local.lb_subnet_ad2
  compartment_id             = var.compartment_ocid
  display_name               = "${var.label_prefix}-lb-ad2"
  dns_label                  = "lb2"
  prohibit_public_ip_on_vnic = false
  route_table_id             = var.ig_route_id
  security_list_ids          = [oci_core_security_list.lb_seclist.id]
  vcn_id                     = var.vcn_id

  count = var.availability_domains["lb_ad2"] == 2 ? 1 : 0
}

resource "oci_core_subnet" "lb_ad3" {
  availability_domain        = length(var.ad_names) == 3 ? element(var.ad_names, 2) : element(var.ad_names, 0)
  cidr_block                 = local.lb_subnet_ad3
  compartment_id             = var.compartment_ocid
  display_name               = "${var.label_prefix}-lb-ad3"
  dns_label                  = "lb3"
  prohibit_public_ip_on_vnic = false
  route_table_id             = var.ig_route_id
  security_list_ids          = [oci_core_security_list.lb_seclist.id]
  vcn_id                     = var.vcn_id

  count = var.availability_domains["lb_ad3"] == 3 ? 1 : 0
}

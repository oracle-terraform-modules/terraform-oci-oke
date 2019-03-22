# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

module "vcn" {
  source                 = "./vcn"
  compartment_ocid       = "${var.compartment_ocid}"
  tenancy_ocid           = "${var.tenancy_ocid}"
  vcn_dns_name           = "${var.vcn_dns_name}"
  label_prefix           = "${var.label_prefix}"
  vcn_name               = "${var.vcn_name}"
  vcn_cidr               = "${var.vcn_cidr}"
  newbits                = "${var.newbits}"
  subnets                = "${var.subnets}"
  ad_names               = "${data.template_file.ad_names.*.rendered}"
  availability_domains   = "${var.availability_domains}"
  create_nat_gateway     = "${var.create_nat_gateway}"
  nat_gateway_name       = "${var.nat_gateway_name}"
  create_service_gateway = "${var.create_service_gateway}"
  service_gateway_name   = "${var.service_gateway_name}"
}

module "bastion" {
  source                  = "./bastion"
  tenancy_ocid            = "${var.tenancy_ocid}"
  user_ocid               = "${var.user_ocid}"
  api_fingerprint         = "${var.api_fingerprint}"
  region                  = "${var.region}"
  vcn_id                  = "${module.vcn.vcn_id}"
  compartment_ocid        = "${var.compartment_ocid}"
  compartment_name        = "${var.compartment_name}"
  api_fingerprint         = "${var.api_fingerprint}"
  api_private_key_path    = "${var.api_private_key_path}"
  ssh_public_key_path     = "${var.ssh_public_key_path}"
  ssh_private_key_path    = "${var.ssh_private_key_path}"
  preferred_bastion_image = "${var.preferred_bastion_image}"
  image_ocid              = "${var.imageocids["${var.preferred_bastion_image}-${var.region}"]}"
  ad_names                = "${data.template_file.ad_names.*.rendered}"
  availability_domains    = "${var.availability_domains}"
  label_prefix            = "${var.label_prefix}"
  bastion_shape           = "${var.bastion_shape}"
  bastion_subnet_ids      = "${module.vcn.bastion_subnet_ids}"
}

# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

module "vcn" {
  source                 = "./vcn"
  compartment_ocid       = "${var.compartment_ocid}"
  label_prefix           = "${var.label_prefix}"
  create_nat_gateway     = "${var.create_nat_gateway}"
  nat_gateway_name       = "${var.nat_gateway_name}"
  create_service_gateway = "${var.create_service_gateway}"
  service_gateway_name   = "${var.service_gateway_name}"
  vcn_cidr               = "${var.vcn_cidr}"
  vcn_dns_name           = "${var.vcn_dns_name}"
  vcn_name               = "${var.vcn_name}"
}

module "bastion" {
  source                  = "./bastion"
  api_fingerprint         = "${var.api_fingerprint}"
  api_private_key_path    = "${var.api_private_key_path}"
  compartment_ocid        = "${var.compartment_ocid}"
  label_prefix            = "${var.label_prefix}"
  region                  = "${var.region}"
  ssh_public_key_path     = "${var.ssh_public_key_path}"
  ssh_private_key_path    = "${var.ssh_private_key_path}"
  bastion_shape           = "${var.bastion_shape}"
  create_bastion          = "${var.create_bastion}"
  image_ocid              = "${var.imageocids["${var.preferred_bastion_image}-${var.region}"]}"
  preferred_bastion_image = "${var.preferred_bastion_image}"
  ig_route_id             = "${module.vcn.ig_route_id}"
  newbits                 = "${var.newbits}"
  subnets                 = "${var.subnets}"
  vcn_cidr                = "${var.vcn_cidr}"
  vcn_id                  = "${module.vcn.vcn_id}"
  ad_names                = "${data.template_file.ad_names.*.rendered}"
  availability_domains    = "${var.availability_domains}"
}

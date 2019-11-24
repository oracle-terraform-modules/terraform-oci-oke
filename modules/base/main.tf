# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

module "vcn" {
  source       = "./vcn"
  oci_base_vcn = local.oci_base_vcn
}

module "bastion" {
  source                   = "./bastion"
  oci_base_identity        = var.oci_base_identity
  oci_bastion_general      = local.oci_bastion_general
  oci_bastion_network        = local.oci_bastion_network
  oci_bastion              = local.oci_bastion
  oci_bastion_notification = local.oci_bastion_notification
}

module "admin" {
  source                 = "./admin"
  oci_admin_identity     = var.oci_base_identity
  oci_admin_general      = local.oci_bastion_general
  oci_admin_network      = local.oci_admin_network
  oci_admin              = local.oci_admin
  oci_admin_notification = local.oci_admin_notification
}

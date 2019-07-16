# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

module "vcn" {
  source       = "./vcn"
  oci_base_vcn = local.oci_base_vcn
}

module "bastion" {
  source              = "./bastion"
  oci_base_identity   = var.oci_base_identity
  oci_bastion_general = local.oci_bastion_general
  oci_bastion_infra   = local.oci_bastion_infra
  oci_bastion         = local.oci_bastion
  oci_base_ssh_keys   = var.oci_base_ssh_keys
}

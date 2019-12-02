# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "oci_identity_policy" "admin_instance_principal_dynamic_group" {
  provider       = oci.home
  compartment_id = var.oci_identity.tenancy_id
  description    = "policy to allow admin host to manage dynamic group"
  name           = "${var.label_prefix}-admin-instance-principal-dynamic-group"
  statements     = ["Allow dynamic-group ${var.dynamic_group} to use dynamic-groups in tenancy"]
  count          = (var.oke_kms.use_encryption == true && var.admin.bastion_enabled == true && var.admin.admin_instance_principal == true) ? 1 : 0
}

resource "oci_identity_policy" "oke-kms" {
  provider       = oci.home
  compartment_id = var.oci_identity.compartment_id
  description    = "policy to allow instances to allow dynamic group ${var.label_prefix}-oke-kms-cluster to use kms"
  name           = "${var.label_prefix}-oke-kms"
  statements     = [local.policy_statement]
  count          = (var.oke_kms.use_encryption == true) ? 1 : 0
}
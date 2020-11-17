# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "oci_identity_policy" "operator_instance_principal_dynamic_group" {
  provider       = oci.home
  compartment_id = var.tenancy_id
  description    = "policy to allow operator host to manage dynamic group"
  name           = var.label_prefix == "none" ? "operator-instance-principal-dynamic-group-${substr(uuid(),0,8)}" : "${var.label_prefix}-operator-instance-principal-dynamic-group-${substr(uuid(),0,8)}"
  statements     = ["Allow dynamic-group ${var.dynamic_group} to use dynamic-groups in tenancy"]
  count          = (var.oke_kms.use_encryption == true && var.operator.bastion_enabled == true && var.operator.operator_instance_principal == true) ? 1 : 0
}

resource "oci_identity_policy" "oke-kms" {
  provider       = oci.home
  compartment_id = var.compartment_id
  description    = "policy to allow instances to allow dynamic group ${var.label_prefix}-oke-kms-cluster to use kms"
  name           = var.label_prefix == "none" ? "oke-kms" : "${var.label_prefix}-oke-kms"
  statements     = [local.policy_statement]
  count          = (var.oke_kms.use_encryption == true) ? 1 : 0
}
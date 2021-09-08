# Copyright 2017, 2021 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "oci_identity_policy" "oke_kms" {
  provider       = oci.home
  compartment_id = var.compartment_id
  description    = "policy to allow dynamic group ${var.label_prefix}-oke-kms-cluster to use kms"
  depends_on     = [oci_identity_dynamic_group.oke_kms_cluster]
  name           = var.label_prefix == "none" ? "oke-kms" : "${var.label_prefix}-oke-kms"
  statements     = [local.policy_statement]
  count          = var.use_encryption == true ? 1 : 0
}

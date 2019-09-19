# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_identity_policy" "oke-kms" {
  provider       = "oci.home"
  compartment_id = var.oci_identity.compartment_ocid
  description    = "policy to allow instances to allow dynamic group ${var.label_prefix}-oke-kms-cluster to use kms"
  name           = "${var.label_prefix}-oke-kms"
  statements     = [local.policy_statement]
  count          = var.oke_kms.use_encryption == true ? 1 : 0
}
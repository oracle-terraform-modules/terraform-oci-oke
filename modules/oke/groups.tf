# Copyright 2017, 2021 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "oci_identity_dynamic_group" "oke_kms_cluster" {
  provider       = oci.home
  compartment_id = var.tenancy_id
  description    = "dynamic group to allow cluster to use kms"
  matching_rule  = local.dynamic_group_rule_all_clusters
  name           = var.label_prefix == "none" ? "oke-kms-cluster" : "${var.label_prefix}-oke-kms-cluster"
  count          = var.use_encryption == true ? 1 : 0

  lifecycle {
    ignore_changes = [matching_rule]
  }
}

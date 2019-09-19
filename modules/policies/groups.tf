# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_identity_dynamic_group" "oke-kms-cluster" {
  provider       = "oci.home"
  compartment_id = var.oci_identity.tenancy_ocid
  description    = "dynamic group to allow cluster to use kms"
  matching_rule  = local.dynamic_group_rule_all_clusters
  # matching_rule  = local.dynamic_group_rule_this_cluster
  name           = "${var.label_prefix}-oke-kms-cluster"
  count          = var.oke_kms.use_encryption == true ? 1 : 0
}
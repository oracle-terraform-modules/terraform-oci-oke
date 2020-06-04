# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {

  dynamic_group_rule_all_clusters = (var.oke_kms.use_encryption == true) ? "ALL {resource.type = 'cluster', resource.compartment.id = '${var.compartment_id}'}" : null

  dynamic_group_rule_this_cluster = (var.oke_kms.use_encryption == true) ? "ALL {resource.type = 'cluster', resource.id = '${var.cluster_id}'}" : null

  policy_statement = (var.oke_kms.use_encryption == true) ? "Allow dynamic-group ${oci_identity_dynamic_group.oke-kms-cluster[0].name} to use keys in compartment id ${var.compartment_id} where target.key.id = '${var.oke_kms.key_id}'" : ""
}

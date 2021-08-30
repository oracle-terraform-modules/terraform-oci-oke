# Copyright 2017, 2021 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {

  dynamic_group_rule_all_clusters = (var.use_encryption == true) ? "ALL {resource.type = 'cluster', resource.compartment.id = '${var.compartment_id}'}" : "null"

  dynamic_group_rule_this_cluster = (var.use_encryption == true) ? "ALL {resource.type = 'cluster', resource.id = '${var.cluster_id}'}" : "null"

  policy_statement = (var.use_encryption == true) ? "Allow dynamic-group ${oci_identity_dynamic_group.oke_kms_cluster[0].name} to use keys in compartment id ${var.compartment_id} where target.key.id = '${var.key_id}'" : ""

  update_dynamic_group_template = templatefile("${path.module}/scripts/update_dynamic_group.template.sh",
    {
      dynamic_group_id   = var.use_encryption == true ? oci_identity_dynamic_group.oke_kms_cluster[0].id : "null"
      dynamic_group_rule = local.dynamic_group_rule_this_cluster
      home_region        = data.oci_identity_regions.home_region.regions[0].name
    }
  )

}

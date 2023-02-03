# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  cluster_group_name = "oke-cluster-${var.state_id}"
  cluster_rule = format("ALL {%s}", join(", ", compact([
    "resource.type = 'cluster'",
    "resource.compartment.id = '${var.compartment_id}'",
    var.use_defined_tags ? "tag.${var.tag_namespace}.state_id.value='${var.state_id}'" : null,
  ])))

  # Cluster secrets encryption using OCI Key Management System (KMS)
  cluster_policy_statements = coalesce(var.cluster_kms_key_id, "none") != "none" ? tolist([format(
    "Allow dynamic-group %s to use keys in compartment id %s where target.key.id = '%s'",
    local.cluster_group_name, var.compartment_id, var.cluster_kms_key_id,
  )]) : []
}

resource "oci_identity_dynamic_group" "cluster" {
  provider       = oci.home
  count          = var.create_iam_resources && var.create_iam_kms_policy ? 1 : 0
  compartment_id = var.tenancy_id # dynamic groups exist in root compartment (tenancy)
  description    = "Dynamic group with cluster for OKE Terraform state ${var.state_id}"
  matching_rule  = local.cluster_rule
  name           = local.cluster_group_name
  defined_tags   = local.defined_tags
  freeform_tags  = local.freeform_tags
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

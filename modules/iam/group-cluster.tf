# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  cluster_group_name = format("oke-cluster-%v", var.state_id)
  cluster_rule = format("ALL {%v}", join(", ", compact([
    "resource.type = 'cluster'",
    format("resource.compartment.id = '%v'", var.compartment_id),
    var.use_defined_tags ? format("tag.%v.state_id.value='%v'",
    var.tag_namespace, var.state_id) : null,
  ])))

  # Cluster secrets encryption using OCI Key Management System (KMS)
  cluster_policy_statements = coalesce(var.cluster_kms_key_id, "none") != "none" ? tolist([format(
    "Allow dynamic-group %v to use keys in compartment id %v where target.key.id = '%v'",
    local.cluster_group_name, var.compartment_id, var.cluster_kms_key_id,
  ), format("Allow dynamic-group %v to read instance-images in compartment id %v",
    local.cluster_group_name, var.compartment_id)
  ]) : []
}

resource "oci_identity_dynamic_group" "cluster" {
  provider       = oci.home
  count          = var.create_iam_resources && var.create_iam_kms_policy ? 1 : 0
  compartment_id = var.tenancy_id # dynamic groups exist in root compartment (tenancy)
  description    = format("Dynamic group with cluster for OKE Terraform state %v", var.state_id)
  matching_rule  = local.cluster_rule
  name           = local.cluster_group_name
  defined_tags   = local.defined_tags
  freeform_tags  = local.freeform_tags
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

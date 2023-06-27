# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  worker_group_name          = format("oke-workers-%v", var.state_id)
  worker_compartments        = coalescelist(var.worker_compartments, [var.compartment_id])
  worker_compartment_matches = formatlist("instance.compartment.id = '%v'", local.worker_compartments)
  worker_compartment_rule    = format("ANY {%v}", join(", ", local.worker_compartment_matches))

  worker_group_rules = var.use_defined_tags ? format("ALL {%v}", join(", ", [
    format("tag.%v.role.value='worker'", var.tag_namespace),
    format("tag.%v.state_id.value='%v'", var.tag_namespace, var.state_id),
  ])) : local.worker_compartment_rule

  cluster_join_where_clause = format("ALL {%v}", join(", ", compact([
    var.create_iam_worker_policy && var.cluster_id != null
    ? format("target.cluster.id = %v", var.cluster_id) : null
  ])))

  cluster_join_statements = formatlist(
    "Allow dynamic-group %v to {CLUSTER_JOIN} in compartment id %v where %v",
    local.worker_group_name, local.worker_compartments, local.cluster_join_where_clause
  )

  # TODO support keys defined at worker group level
  worker_kms_volume_templates = tolist([
    "Allow service oke to USE key-delegates in compartment id %v where target.key.id = '%v'",
    "Allow service blockstorage to USE keys in compartment id %v where target.key.id = '%v'",
    "Allow dynamic-group ${local.worker_group_name} to USE key-delegates in compartment id %v where target.key.id = '%v'"
  ])

  # Block volume encryption using OCI Key Management System (KMS)
  worker_kms_volume_statements = coalesce(var.worker_volume_kms_key_id, "none") != "none" ? flatten(tolist([
    for statement in local.worker_kms_volume_templates :
    formatlist(statement, local.worker_compartments, var.worker_volume_kms_key_id)
  ])) : []

  worker_policy_statements = var.create_iam_worker_policy ? tolist(concat(
    local.cluster_join_statements,
    local.worker_kms_volume_statements,
  )) : []
}

resource "oci_identity_dynamic_group" "workers" {
  provider       = oci.home
  count          = var.create_iam_resources && var.create_iam_worker_policy ? 1 : 0
  compartment_id = var.tenancy_id # dynamic groups exist in root compartment (tenancy)
  description    = format("Dynamic group of self-managed worker nodes for OKE Terraform state %v", var.state_id)
  matching_rule  = local.worker_group_rules
  name           = local.worker_group_name
  defined_tags   = local.defined_tags
  freeform_tags  = local.freeform_tags
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

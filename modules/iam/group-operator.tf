# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  operator_group_name = format("oke-operator-%v", var.state_id)
  operator_group_rules = var.use_defined_tags ? format("ALL {%v}", join(", ", [
    format("tag.%v.role.value='operator'", var.tag_namespace),
    format("tag.%v.state_id.value='%v'", var.tag_namespace, var.state_id),
  ])) : "ALL {instance.compartment.id = '${var.compartment_id}'}"

  cluster_manage_statement = format(
    "Allow dynamic-group %v to MANAGE clusters in compartment id %v",
    local.operator_group_name, var.compartment_id,
  )

  # TODO support keys defined at worker group level
  operator_kms_volume_templates = [
    "Allow service blockstorage to USE keys in compartment id %v where target.key.id = '%v'",
    "Allow dynamic-group ${local.operator_group_name} to USE key-delegates in compartment id %v where target.key.id = '%v'"
  ]

  # Block volume encryption using OCI Key Management System (KMS)
  operator_kms_volume_statements = coalesce(var.operator_volume_kms_key_id, "none") != "none" ? tolist([
    for statement in local.operator_kms_volume_templates :
    format(statement, var.compartment_id, var.operator_volume_kms_key_id)
  ]) : []

  operator_policy_statements = var.create_iam_operator_policy ? concat(
    [local.cluster_manage_statement],
    local.operator_kms_volume_statements,
  ) : []
}

resource "oci_identity_dynamic_group" "operator" {
  provider       = oci.home
  count          = var.create_iam_resources && var.create_iam_operator_policy ? 1 : 0
  compartment_id = var.tenancy_id # dynamic groups exist in root compartment (tenancy)
  description    = format("Dynamic group of operator instance(s) for OKE Terraform state %v", var.state_id)
  matching_rule  = local.operator_group_rules
  name           = local.operator_group_name
  defined_tags   = local.defined_tags
  freeform_tags  = local.freeform_tags
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

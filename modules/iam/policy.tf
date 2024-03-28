# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  policy_statements_before_cluster = distinct(compact(flatten([
    local.cluster_policy_statements,
  ])))

  has_policy_statements_before_cluster = var.create_iam_resources && anytrue([
    var.create_iam_kms_policy,
  ])

  policy_statements_after_cluster = distinct(compact(flatten([
    local.worker_policy_statements,
    local.operator_policy_statements,
    local.autoscaler_policy_statements,
  ])))

  has_policy_statements_after_cluster = var.create_iam_resources && anytrue([
    var.create_iam_autoscaler_policy,
    var.create_iam_operator_policy,
    var.create_iam_worker_policy,
  ])
}

resource "oci_identity_policy" "before_cluster" {
  provider       = oci.home
  count          = local.has_policy_statements_before_cluster ? 1 : 0
  compartment_id = var.compartment_id
  description    = format("Policies for OKE Terraform state %v", var.state_id)
  name           = format("%s-before-cluster", local.cluster_group_name)
  statements     = local.policy_statements_before_cluster
  defined_tags   = local.defined_tags
  freeform_tags  = local.freeform_tags
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

resource "oci_identity_policy" "after_cluster" {
  provider       = oci.home
  count          = local.has_policy_statements_after_cluster ? 1 : 0
  compartment_id = var.compartment_id
  description    = format("Policies for OKE Terraform state %v", var.state_id)
  name           = format("%s-after-cluster", local.cluster_group_name)
  statements     = local.policy_statements_after_cluster
  defined_tags   = local.defined_tags
  freeform_tags  = local.freeform_tags
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

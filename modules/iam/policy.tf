# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  policy_statements = distinct(compact(flatten([
    local.cluster_policy_statements,
    local.worker_policy_statements,
    local.operator_policy_statements,
    local.autoscaler_policy_statements,
  ])))

  has_policy_statements = var.create_iam_resources && anytrue([
    var.create_iam_autoscaler_policy,
    var.create_iam_kms_policy,
    var.create_iam_operator_policy,
    var.create_iam_worker_policy,
  ])
}

resource "oci_identity_policy" "cluster" {
  provider       = oci.home
  count          = var.create_iam_resources && local.has_policy_statements ? 1 : 0
  compartment_id = var.compartment_id
  description    = "Policies for OKE Terraform state ${var.state_id}"
  name           = local.cluster_group_name
  statements     = local.policy_statements
  defined_tags   = local.defined_tags
  freeform_tags  = local.freeform_tags
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

resource "time_sleep" "await_iam_policy" { # Allow policies to take effect globally before continuing
  count            = local.has_policy_statements ? 1 : 0
  create_duration  = "30s"
  destroy_duration = "0s"
  depends_on       = [oci_identity_policy.cluster]
}

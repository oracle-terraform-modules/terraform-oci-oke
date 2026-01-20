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
  count          = local.has_policy_statements ? 1 : 0
  compartment_id = var.compartment_id
  description    = format("Policies for OKE Terraform state %v", var.state_id)
  name           = var.policy_name
  statements     = local.policy_statements
  defined_tags   = local.defined_tags
  freeform_tags  = local.freeform_tags
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

resource "oci_identity_policy" "networking_policies" {
  provider       = oci.home
  count          = alltrue([var.create_iam_resources, var.create_iam_cluster_policy]) ? 1 : 0
  compartment_id = var.network_compartment_id != null ? var.network_compartment_id : var.compartment_id
  description    = format("Policies for OKE Terraform state %v", var.state_id)
  name           = format("%v-network", var.policy_name)
  statements     = compact([
    var.enable_ipv6 ? format("Allow any-user to use ipv6s in compartment id %v where all { request.principal.type = 'cluster' }", coalesce(var.network_compartment_id, var.compartment_id)) : null,
    format("Allow any-user to manage network-security-groups in compartment id %v where request.principal.type = 'cluster'", coalesce(var.network_compartment_id, var.compartment_id)),
  ])
  defined_tags   = local.defined_tags
  freeform_tags  = local.freeform_tags
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}
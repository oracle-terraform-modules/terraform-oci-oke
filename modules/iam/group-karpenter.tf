# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  karpenter_group_name          = format("oke-karpenter-%v", var.state_id)
  karpenter_worker_compartments = coalescelist(var.karpenter_worker_compartments, [var.compartment_id])
  karpenter_compartment_matches = formatlist("instance.compartment.id = '%v'", local.karpenter_worker_compartments)
  karpenter_group_rules         = format("ANY {%v}", join(", ", local.karpenter_compartment_matches))

  karpenter_dynamic_group_templates = [
    "Allow dynamic-group %v to {CLUSTER_JOIN} in compartment id %v",
  ]

  karpenter_dynamic_group_policy_statements = var.create_iam_karpenter_policy ? tolist([
    for statement in local.karpenter_dynamic_group_templates : formatlist(statement,
      local.karpenter_group_name, local.karpenter_worker_compartments,
    )
  ]) : []

  karpenter_workload_identity_templates = compact([
    "Allow any-user to manage instance-family in compartment id %v where all { request.principal.type='workload', request.principal.cluster_id = '%v', request.principal.namespace = '%v', request.principal.service_account = 'karpenter' }",
    "Allow any-user to manage volumes in compartment id %v where all { request.principal.type='workload', request.principal.cluster_id = '%v', request.principal.namespace = '%v', request.principal.service_account = 'karpenter' }",
    "Allow any-user to manage volume-attachments in compartment id %v where all { request.principal.type='workload', request.principal.cluster_id = '%v', request.principal.namespace = '%v', request.principal.service_account = 'karpenter' }",
    "Allow any-user to manage virtual-network-family in compartment id %v where all { request.principal.type='workload', request.principal.cluster_id = '%v', request.principal.namespace = '%v', request.principal.service_account = 'karpenter' }",
    "Allow any-user to inspect compartments in compartment id %v where all { request.principal.type='workload', request.principal.cluster_id = '%v', request.principal.namespace = '%v', request.principal.service_account = 'karpenter' }",
    var.karpenter_optional_policies.capacity_reservation ? "Allow any-user to use compute-capacity-reservations in compartment id %v where all { request.principal.type='workload', request.principal.cluster_id = '%v', request.principal.namespace = '%v', request.principal.service_account = 'karpenter' }" : "",
    var.karpenter_optional_policies.compute_clusters ? "Allow any-user to use compute-clusters in compartment id %v where all { request.principal.type='workload', request.principal.cluster_id = '%v', request.principal.namespace = '%v', request.principal.service_account = 'karpenter' }" : "",
    var.karpenter_optional_policies.cluster_placement_groups ? "Allow any-user to use cluster-placement-groups in compartment id %v where all { request.principal.type='workload', request.principal.cluster_id = '%v', request.principal.namespace = '%v', request.principal.service_account = 'karpenter' }" : "",
    var.karpenter_optional_policies.defined_tags ? "Allow any-user to use tag-namespaces in compartment id %v where all { request.principal.type='workload', request.principal.cluster_id = '%v', request.principal.namespace = '%v', request.principal.service_account = 'karpenter' }" : "",
  ])

  karpenter_workload_identity_policy_statements = var.create_iam_karpenter_policy ? tolist([
    for statement in local.karpenter_workload_identity_templates : formatlist(statement,
      local.karpenter_worker_compartments, var.cluster_id, var.karpenter_namespace
    )
  ]) : []

  karpenter_policy_statements = concat(local.karpenter_dynamic_group_policy_statements, local.karpenter_workload_identity_policy_statements)
}

resource "oci_identity_dynamic_group" "karpenter" {
  provider       = oci.home
  count          = var.create_iam_resources && var.create_iam_karpenter_policy ? 1 : 0
  compartment_id = var.tenancy_id # dynamic groups exist in root compartment (tenancy)
  description    = format("Dynamic group of karpenter worker nodes for OKE Terraform state %v", var.state_id)
  matching_rule  = local.karpenter_group_rules
  name           = local.karpenter_group_name
  defined_tags   = local.defined_tags
  freeform_tags  = local.freeform_tags
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

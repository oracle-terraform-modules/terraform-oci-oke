# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  autoscaler_group_name          = format("oke-autoscaler-%v", var.state_id)
  autoscaler_compartments        = coalescelist(var.autoscaler_compartments, [var.compartment_id])
  autoscaler_compartment_matches = formatlist("instance.compartment.id = '%v'", local.autoscaler_compartments)
  autoscaler_compartment_rule    = format("ANY {%v}", join(", ", local.autoscaler_compartment_matches))

  autoscaler_group_rules = var.use_defined_tags ? format("ALL {%v}", join(", ", [
    format("tag.%v.role.value='worker'", var.tag_namespace),
    format("tag.%v.cluster_autoscaler.value='allowed'", var.tag_namespace),
    local.autoscaler_compartment_rule,
    # "tag.${var.tag_namespace}.state_id.value='${var.state_id}'", # TODO optional use w/ config
  ])) : local.autoscaler_compartment_rule

  autoscaler_nodepool_policy_templates = [
    "Allow dynamic-group %v to manage cluster-node-pools in compartment id %v",
    "Allow dynamic-group %v to manage instance-family in compartment id %v",
  ]

  autoscaler_shared_network_policy_templates = [
    "Allow dynamic-group %v to use subnets in compartment id %v",
    "Allow dynamic-group %v to use vnics in compartment id %v",
    "Allow dynamic-group %v to inspect compartments in compartment id %v",
  ]

  autoscaler_vcn_read_policy_template = "Allow dynamic-group %v to read virtual-network-family in compartment id %v"

  autoscaler_policy_templates = concat(
    local.autoscaler_nodepool_policy_templates,
    local.autoscaler_shared_network_policy_templates,
    var.network_compartment_id == null ? [local.autoscaler_vcn_read_policy_template] : [],
  )

  autoscaler_policy_statements = var.create_iam_autoscaler_policy ? flatten([
    for statement in local.autoscaler_policy_templates : formatlist(
      statement, local.autoscaler_group_name, local.worker_compartments,
    )
  ]) : []

  autoscaler_network_policy_statements = var.create_iam_autoscaler_policy && var.network_compartment_id != null ? [
    for statement in concat(
      local.autoscaler_shared_network_policy_templates, [local.autoscaler_vcn_read_policy_template],
    ) : format(statement, local.autoscaler_group_name, var.network_compartment_id)
  ] : []
}

resource "oci_identity_dynamic_group" "autoscaling" {
  provider       = oci.home
  count          = var.create_iam_resources && var.create_iam_autoscaler_policy ? 1 : 0
  compartment_id = var.tenancy_id # dynamic groups exist in root compartment (tenancy)
  description    = format("Dynamic group of cluster autoscaler-capable worker nodes for OKE Terraform state %v", var.state_id)
  matching_rule  = local.autoscaler_group_rules
  name           = local.autoscaler_group_name
  defined_tags   = local.defined_tags
  freeform_tags  = local.freeform_tags
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

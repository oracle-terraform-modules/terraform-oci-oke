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

  autoscaler_templates = [
    "Allow dynamic-group %v to manage cluster-node-pools in compartment id %v",
    "Allow dynamic-group %v to manage compute-management-family in compartment id %v",
    "Allow dynamic-group %v to manage instance-family in compartment id %v",
    "Allow dynamic-group %v to manage volume-family in compartment id %v",
    "Allow dynamic-group %v to use subnets in compartment id %v",
    "Allow dynamic-group %v to read virtual-network-family in compartment id %v",
    "Allow dynamic-group %v to use vnics in compartment id %v",
    "Allow dynamic-group %v to inspect compartments in compartment id %v",
  ]

  autoscaler_policy_statements = var.create_iam_autoscaler_policy ? tolist([
    for statement in local.autoscaler_templates : formatlist(statement,
      local.autoscaler_group_name, local.worker_compartments,
    )
  ]) : []
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

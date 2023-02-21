# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

data "oci_identity_availability_domains" "all" {
  compartment_id = local.compartment_id
}

locals {
  // Tenancy-specific availability domains in region
  // Common reference for data source re-used throughout module
  ads = data.oci_identity_availability_domains.all.availability_domains

  // Map of parsed availability domain numbers to tenancy-specific names
  // Used by resources with AD placement for generic selection
  ad_numbers_to_names = local.ads != null ? {
    for ad in local.ads : parseint(substr(ad.name, -1, -1), 10) => ad.name
  } : { -1 : "" } # Fallback handles failure when unavailable but not required

  // List of availability domain numbers in region
  // Used to intersect desired AD lists against presence in region
  ad_numbers = local.ads != null ? sort(keys(local.ad_numbers_to_names)) : []

  create_iam_worker_policy = anytrue([
    var.create_iam_worker_policy == "always",
    var.create_iam_worker_policy == "auto" && var.create_cluster && anytrue([for k, v in var.worker_pools :
      tobool(lookup(v, "create", true)) &&
      lookup(v, "mode", var.worker_pool_mode) != "node-pool"
    ])
  ])

  create_iam_autoscaler_policy = anytrue([
    var.create_iam_autoscaler_policy == "always",
    var.create_iam_autoscaler_policy == "auto" && var.create_cluster && anytrue([for k, v in var.worker_pools :
      tobool(lookup(v, "create", true)) &&
      tobool(lookup(v, "allow_autoscaler", false))
    ])
  ])

  create_iam_operator_policy = anytrue([
    var.create_iam_operator_policy == "always",
    var.create_iam_operator_policy == "auto" && local.operator_enabled
  ])

  create_iam_kms_policy = anytrue([
    var.create_iam_kms_policy == "always",
    var.create_iam_kms_policy == "auto" && anytrue([
      coalesce(var.worker_volume_kms_key_id, "none") != "none",
      coalesce(var.cluster_kms_key_id, "none") != "none",
    ])
  ])
}

# Default IAM sub-module implementation for OKE cluster
module "iam" {
  source                       = "./modules/iam"
  compartment_id               = local.compartment_id
  state_id                     = random_id.state_id.id
  tenancy_id                   = local.tenancy_id
  cluster_id                   = local.cluster_id
  create_iam_resources         = var.create_iam_resources
  create_iam_autoscaler_policy = local.create_iam_autoscaler_policy
  create_iam_kms_policy        = local.create_iam_kms_policy
  create_iam_operator_policy   = local.create_iam_operator_policy
  create_iam_worker_policy     = local.create_iam_worker_policy

  create_iam_tag_namespace = var.create_iam_tag_namespace
  create_iam_defined_tags  = var.create_iam_defined_tags
  defined_tags             = lookup(var.defined_tags, "policy", {})
  freeform_tags            = lookup(var.freeform_tags, "policy", {})
  tag_namespace            = var.tag_namespace
  use_defined_tags         = var.use_defined_tags

  cluster_kms_key_id         = var.cluster_kms_key_id
  operator_volume_kms_key_id = var.operator_volume_kms_key_id
  worker_volume_kms_key_id   = var.worker_volume_kms_key_id

  autoscaler_compartments = local.autoscaler_compartments
  worker_compartments     = local.worker_compartments

  providers = {
    oci.home = oci.home
  }
}

output "availability_domains" {
  description = "Availability domains for tenancy & region"
  value       = local.ad_numbers_to_names
}

output "dynamic_group_ids" {
  description = "Cluster IAM dynamic group IDs"
  value       = module.iam.dynamic_group_ids
}

output "policy_statements" {
  description = "Cluster IAM policy statements"
  value       = module.iam.policy_statements
}

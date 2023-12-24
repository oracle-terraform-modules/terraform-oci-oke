# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

data "oci_identity_tag_namespaces" "oke" {
  count          = var.create_iam_resources ? 1 : 0
  provider       = oci.home
  compartment_id = var.compartment_id
  filter {
    name   = "name"
    values = [var.tag_namespace]
  }

  state = "ACTIVE" // TODO Support reactivation of retired namespace w/ update
}

locals {
  # Filtered value from data source (only 1 by name, or null)
  # Identified tag namespace ID when not created and used
  tag_namespace_id_found = one(
    one(data.oci_identity_tag_namespaces.oke[*].tag_namespaces)[*].id
  )

  create_iam_tag_namespace = alltrue([
    var.create_iam_resources,
    var.create_iam_tag_namespace,
    local.tag_namespace_id_found == null,
  ])

  # Map of standard tags & descriptions to be created if enabled
  tags = var.create_iam_resources && var.create_iam_defined_tags ? {
    "role"               = "Functional role of a resource"
    "state_id"           = "Terraform state ID associated with a resource"
    "cluster_autoscaler" = "Granted permissions for Kubernetes cluster autoscaler"
    "pool"               = "Named group of resources with shared configuration"
  } : {}

  # Standard tags as freeform if defined tags are disabled
  freeform_tags = merge(var.freeform_tags, !var.use_defined_tags ? {
    "state_id" = var.state_id,
    "role"     = "iam",
    } : {},
  )

  # Standard tags as defined if enabled for use
  defined_tags = merge(var.defined_tags, var.use_defined_tags ? {
    "${var.tag_namespace}.state_id" = var.state_id,
    "${var.tag_namespace}.role"     = "iam",
    } : {},
  )
}

resource "oci_identity_tag_namespace" "oke" {
  provider       = oci.home
  count          = local.create_iam_tag_namespace ? 1 : 0
  compartment_id = var.compartment_id
  description    = "Tag namespace for OKE resources"
  name           = var.tag_namespace
  # defined_tags   = local.defined_tags
  freeform_tags = local.freeform_tags
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

resource "oci_identity_tag" "oke" {
  provider    = oci.home
  for_each    = local.create_iam_tag_namespace ? local.tags : {} #{ for k, v in oci_identity_tag_namespace.oke : k => local.tags } # local.create_iam_tag_namespace ? local.tags : {}
  description = each.value
  name        = each.key
  # defined_tags     = local.defined_tags
  freeform_tags    = local.freeform_tags
  tag_namespace_id = one(oci_identity_tag_namespace.oke[*].id)

  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

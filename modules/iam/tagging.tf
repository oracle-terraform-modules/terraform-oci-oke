# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

data "oci_identity_tag_namespaces" "oke" {
  provider       = oci.home
  compartment_id = var.compartment_id
  filter {
    name   = "name"
    values = [var.tag_namespace]
  }
  state = "ACTIVE" // TODO Support reactivation of retired namespace w/ update
}

locals {
  tag_namespace = var.create_tag_namespace ? one(oci_identity_tag_namespace.oke[*].id) : one(data.oci_identity_tag_namespaces.oke.tag_namespaces[*].id)
  tags = var.create_defined_tags ? {
    "role"               = "Functional role of a resource"
    "state_id"           = "Terraform state ID associated with a resource"
    "cluster_autoscaler" = "Granted permissions for Kubernetes cluster autoscaler"
    "pool"               = "Named group of resources with shared configuration"
  } : {}

  defined_tags = merge(var.defined_tags, var.use_defined_tags ? {
    "${var.tag_namespace}.state_id" = var.state_id,
    "${var.tag_namespace}.role"     = "policy",
    } : {},
  )

  freeform_tags = merge(var.freeform_tags, !var.use_defined_tags ? {
    "state_id" = var.state_id,
    "role"     = "policy",
    } : {},
  )
}

resource "oci_identity_tag_namespace" "oke" {
  provider       = oci.home
  count          = var.create_tag_namespace ? 1 : 0
  compartment_id = var.compartment_id
  description    = "Tag namespace for OKE resources"
  name           = var.tag_namespace
  defined_tags   = local.defined_tags
  freeform_tags  = local.freeform_tags
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

resource "oci_identity_tag" "oke" {
  provider         = oci.home
  for_each         = local.tags
  description      = each.value
  name             = each.key
  tag_namespace_id = local.tag_namespace
  defined_tags     = local.defined_tags
  freeform_tags    = local.freeform_tags
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

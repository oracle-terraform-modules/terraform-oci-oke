# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Dynamic resource block for Virtual Node Pool groups defined in worker_pools
resource "oci_containerengine_virtual_node_pool" "workers" {
  # Create an OKE Virtual Node Pool resource for each enabled entry of the worker_pools map with that mode.
  for_each       = local.enabled_virtual_node_pools
  cluster_id     = var.cluster_id
  compartment_id = each.value.compartment_id
  display_name   = each.key
  size           = each.value.size
  defined_tags   = each.value.defined_tags
  freeform_tags  = each.value.freeform_tags
  nsg_ids        = each.value.nsg_ids

  dynamic "placement_configurations" {
    for_each = each.value.availability_domains
    iterator = ad

    content {
      availability_domain = ad.value
      subnet_id           = each.value.subnet_id

      # Intersect the list of available and configured FDs for this AD
      fault_domain = tolist(setintersection(
        try(each.value.placement_fds, local.fault_domains_all),
        lookup(local.fault_domains_available, ad.value, local.fault_domains_all)
      ))
    }
  }

  dynamic "initial_virtual_node_labels" {
    for_each = each.value.node_labels
    content {
      key   = initial_virtual_node_labels.key
      value = initial_virtual_node_labels.value
    }
  }

  pod_configuration {
    shape     = each.value.shape
    subnet_id = coalesce(each.value.pod_subnet_id, each.value.subnet_id)
    nsg_ids   = toset(compact(coalescelist(each.value.pod_nsg_ids, each.value.nsg_ids, [])))
  }

  dynamic "taints" {
    for_each = each.value.taints
    content {
      effect = lookup(taints.value, "effect", "NoSchedule")
      key    = taints.key
      value  = lookup(taints.value, "value", null)
    }
  }

  virtual_node_tags {
    defined_tags  = each.value.defined_tags
    freeform_tags = each.value.freeform_tags
  }

  lifecycle {
    ignore_changes = [
      display_name, virtual_node_tags,
      placement_configurations,
      defined_tags, freeform_tags,
    ]

    precondition {
      condition     = var.cni_type == "npn"
      error_message = "Virtual Node Pools require a cluster with `cni_type = npn`."
    }

    precondition {
      condition     = each.value.autoscale == false
      error_message = "Virtual Node Pools do not support cluster autoscaler management."
    }

    precondition {
      condition     = var.cluster_type == "enhanced"
      error_message = "Virtual Node Pools require `cluster_type = enhanced`."
    }

    precondition {
      condition     = contains(["Pod.Standard.E3.Flex", "Pod.Standard.E4.Flex"], each.value.shape)
      error_message = "Virtual Node Pools must be 'Pod.Standard.E3.Flex' or 'Pod.Standard.E4.Flex'."
    }

    precondition {
      condition = length(local.enabled_modes) == 1
      error_message = format(
        "Mixed mode cluster is not allowed: %#v. Virtual and provisioned node pools cannot be created in the same cluster.",
        local.enabled_modes
      )
    }
  }
}

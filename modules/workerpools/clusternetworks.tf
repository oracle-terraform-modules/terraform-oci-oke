# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Dynamic resource block for Cluster Network groups defined in worker_pools
resource "oci_core_cluster_network" "workers" {
  # Create an OCI Cluster Network resource for each enabled entry of the worker_pools map with that mode.
  for_each       = local.enabled_cluster_networks
  compartment_id = each.value.compartment_id
  display_name   = "${each.value.label_prefix}-${each.key}"
  defined_tags   = merge(local.defined_tags, contains(keys(each.value), "defined_tags") ? each.value.defined_tags : {})
  freeform_tags  = merge(local.freeform_tags, contains(keys(each.value), "freeform_tags") ? each.value.freeform_tags : { worker_pool = each.key })

  instance_pools {
    instance_configuration_id = oci_core_instance_configuration.workers[each.key].id
    display_name              = join("-", compact([lookup(each.value, "label_prefix", var.label_prefix), each.key]))
    size                      = each.value.size
    defined_tags              = merge(coalesce(local.defined_tags, {}), contains(keys(each.value), "defined_tags") ? each.value.defined_tags : {})
    freeform_tags             = merge(coalesce(local.freeform_tags, {}), contains(keys(each.value), "freeform_tags") ? each.value.freeform_tags : { worker_pool = each.key })
  }

  placement_configuration {
    # Define the configured availability domain for placement, bounded to a single value
    # The configured AD number e.g. 2 is converted into a tenancy/compartment-specific name
    availability_domain = lookup(local.ad_number_to_name, (
      contains(keys(each.value), "placement_ads")
      ? element(tolist(setintersection(each.value.placement_ads, local.ad_numbers)), 1)
      : element(local.ad_numbers, 1)
    ), local.first_ad_name)
    primary_subnet_id = each.value.subnet_id
  }

  lifecycle {
    ignore_changes = [
      display_name, defined_tags, freeform_tags,
      instance_pools["display_name"], instance_pools["defined_tags"], instance_pools["freeform_tags"],
      placement_configuration["availability_domain"],
    ]
    precondition {
      condition     = var.cni_type == "flannel"
      error_message = "Cluster Networks require a cluster with `cni_type = flannel`."
    }
  }

  depends_on = [
    oci_core_instance_configuration.workers,
  ]

  # First-boot hardware config for bare metal instances takes extra time
  timeouts {
    create = "2h"
  }
}

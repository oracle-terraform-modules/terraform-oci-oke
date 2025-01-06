# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Dynamic resource block for Cluster Network groups defined in worker_pools
resource "oci_core_cluster_network" "workers" {
  # Create an OCI Cluster Network resource for each enabled entry of the worker_pools map with that mode.
  for_each       = local.enabled_cluster_networks
  compartment_id = each.value.compartment_id
  display_name   = each.key
  defined_tags   = each.value.defined_tags
  freeform_tags  = each.value.freeform_tags

  instance_pools {
    instance_configuration_id = oci_core_instance_configuration.workers[each.key].id
    display_name              = each.key
    size                      = each.value.size
    defined_tags              = each.value.defined_tags
    freeform_tags             = each.value.freeform_tags
  }

  placement_configuration {
    availability_domain = element(each.value.availability_domains, 1)
    primary_subnet_id   = each.value.subnet_id

    dynamic "secondary_vnic_subnets" {
      for_each = lookup(each.value, "secondary_vnics", {})
      iterator = vnic
      content {
        display_name = vnic.key
        subnet_id    = lookup(vnic.value, "subnet_id", each.value.subnet_id)
      }
    }
  }

  lifecycle {
    ignore_changes = [
      display_name, defined_tags, freeform_tags,
      instance_pools[0].defined_tags,
      instance_pools[0].freeform_tags,
    ]

    precondition {
      condition     = coalesce(each.value.image_id, "none") != "none"
      error_message = "Missing image_id for pool ${each.key}. Check provided value for image_id if image_type is 'custom', or image_os/image_os_version if image_type is 'oke' or 'platform'."
    }

    precondition {
      condition     = each.value.autoscale == false
      error_message = "Cluster Networks do not support cluster autoscaler management."
    }
  }

  # First-boot hardware config for bare metal instances takes extra time
  timeouts {
    create = "2h"
  }
}

# Copyright (c) 2026 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# One shared compute cluster per gpu-memory-cluster pool. All GMCs in a pool bind to this compute cluster.
# compute_cluster_id is not updatable on the GMC, so any replacement here cascades into a destroy+create of every GMC bound to it.
resource "oci_core_compute_cluster" "gmc" {
  for_each            = local.enabled_gmc_pools
  compartment_id      = each.value.compartment_id
  display_name        = each.key
  defined_tags        = each.value.defined_tags
  freeform_tags       = each.value.freeform_tags
  availability_domain = element(each.value.availability_domains, 1)

  lifecycle {
    ignore_changes = [
      display_name, defined_tags, freeform_tags,
    ]
  }
}

# One GPU Memory Cluster per (pool, GMF). Keyed by "<pool_name>###<gmf_id>" so list edits don't shift other GMCs.
# Size is omitted: when unset, the OCI control plane sizes the GMC from the fabric's available_host_count.
# lifecycle.ignore_changes keeps ongoing size management with the OCI scaler via gpu_memory_cluster_scale_config.
resource "oci_core_compute_gpu_memory_cluster" "workers" {
  for_each = local.enabled_gmc_fabric_map

  availability_domain       = element(each.value.availability_domains, 1)
  compartment_id            = each.value.compartment_id
  compute_cluster_id        = oci_core_compute_cluster.gmc[each.value.pool_name].id
  instance_configuration_id = oci_core_instance_configuration.workers[each.value.pool_name].id
  gpu_memory_fabric_id      = each.value.gpu_memory_fabric_id
  display_name              = format("%s-%s", each.value.pool_name, substr(each.value.gpu_memory_fabric_id, -11, 11))

  defined_tags  = each.value.defined_tags
  freeform_tags = each.value.freeform_tags

  gpu_memory_cluster_scale_config {
    is_upsize_enabled   = lookup(each.value.gpu_memory_cluster_scale_config, "is_upsize_enabled", var.gmc_scale_is_upsize_enabled)
    is_downsize_enabled = lookup(each.value.gpu_memory_cluster_scale_config, "is_downsize_enabled", var.gmc_scale_is_downsize_enabled)
    target_size         = lookup(each.value.gpu_memory_cluster_scale_config, "target_size", var.gmc_scale_target_size)
  }

  lifecycle {
    precondition {
      condition     = length(each.value.gpu_memory_fabric_ids) == length(toset(each.value.gpu_memory_fabric_ids))
      error_message = "Duplicate GMF OCIDs detected in pool ${each.value.pool_name}'s gpu_memory_fabric_ids list. Each GMF must appear at most once."
    }

    precondition {
      condition     = each.value.autoscale == false
      error_message = "GPU Memory Clusters do not support cluster autoscaler management; the OCI control plane manages scaling via gpu_memory_cluster_scale_config."
    }

    ignore_changes = [
      size,
      gpu_memory_cluster_scale_config,
      defined_tags, freeform_tags, display_name,
    ]
  }
}

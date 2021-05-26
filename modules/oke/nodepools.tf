# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "oci_containerengine_node_pool" "nodepools" {
  for_each       = var.node_pools.node_pools
  cluster_id     = oci_containerengine_cluster.k8s_cluster.id
  compartment_id = var.compartment_id
  depends_on     = [oci_containerengine_cluster.k8s_cluster]

  kubernetes_version = var.oke_cluster.cluster_kubernetes_version
  name               = var.label_prefix == "none" ? each.key : "${var.label_prefix}-${each.key}"

  node_config_details {

    dynamic "placement_configs" {
      iterator = ad_iterator
      for_each = var.ad_names
      content {
        availability_domain = ad_iterator.value
        subnet_id           = var.oke_cluster.cluster_subnets["workers"]
      }
    }
    # set quantity to a minimum of 1 to allow small clusters. 
    size = max(1, lookup(each.value, "node_pool_size", 1))
  }
  dynamic "node_shape_config" {
    for_each = length(regexall("Flex", lookup(each.value, "shape", "VM.Standard.E3.Flex"))) > 0 ? [1] : []
    content {
      ocpus         = max(1, lookup(each.value, "ocpus", 1))
      memory_in_gbs = (lookup(each.value, "memory", 16) / lookup(each.value, "ocpus", 1)) > 64 ? (lookup(each.value, "ocpus", 1) * 64) : lookup(each.value, "memory", 16)
    }
  }
  node_source_details {
    boot_volume_size_in_gbs = lookup(each.value, "boot_volume_size", 50)
    #check is done for GPU,A1 and other shapes.In future if some other shapes or images added we need to modify
    image_id                = (var.node_pools.node_pool_image_id == "none" && length(regexall("GPU|A1",lookup(each.value,"shape"))) == 0) ? (element([for source in local.node_pool_image_ids : source.image_id if length(regexall("Oracle-Linux-${var.node_pools.node_pool_os_version}-20[0-9]*.*", source.source_name)) > 0], 0)) : (var.node_pools.node_pool_image_id == "none" && length(regexall("GPU",lookup(each.value,"shape"))) > 0) ? (element([for source in local.node_pool_image_ids : source.image_id if length(regexall("Oracle-Linux-${var.node_pools.node_pool_os_version}-Gen[0-9]-GPU-20[0-9]*.*", source.source_name)) > 0], 0)) : (var.node_pools.node_pool_image_id == "none" && length(regexall("A1",lookup(each.value,"shape"))) > 0) ? (element([for source in local.node_pool_image_ids : source.image_id if length(regexall("Oracle-Linux-${var.node_pools.node_pool_os_version}-aarch64-20[0-9]*.*", source.source_name)) > 0], 0)) : var.node_pools.node_pool_image_id
    source_type             = data.oci_containerengine_node_pool_option.node_pool_options.sources[0].source_type
  }

  node_shape = lookup(each.value, "shape", "VM.Standard.E3.Flex")

  ssh_public_key = file(var.oke_ssh_keys.ssh_public_key_path)

  # do not destroy the node pool if the kubernetes version has changed as part of the upgrade
  lifecycle {
    ignore_changes = [kubernetes_version]
  }
  dynamic "initial_node_labels" {
    for_each = lookup(each.value, "label", "") != "" ? each.value.label : {}
    content {
      key   = initial_node_labels.key
      value = initial_node_labels.value
    }
  }
}

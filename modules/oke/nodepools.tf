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
    size = max(1, lookup(each.value,"node_pool_size",1))
  }
  dynamic "node_shape_config" {
    for_each = length(regexall("Flex",lookup(each.value,"shape","VM.Standard.E3.Flex"))) > 0 ? [1] : []
    content {
      ocpus = max(1,lookup(each.value,"ocpus",1))
    }
  }
  node_source_details {
    boot_volume_size_in_gbs = lookup(each.value,"boot_volume_size",50)
    image_id    = var.node_pools.node_pool_image_id == "none" ? data.oci_core_images.latest_images[each.key].images[0].id : var.node_pools.node_pool_image_id
    source_type = "IMAGE"
  }

  node_shape = lookup(each.value,"shape","VM.Standard.E3.Flex")

  ssh_public_key = file(var.oke_ssh_keys.ssh_public_key_path)

  lifecycle {
      ignore_changes = [kubernetes_version]
  }
  # initial_node_labels {
  #   key   = "key"
  #   value = "value"
  # }
}
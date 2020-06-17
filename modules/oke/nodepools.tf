# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "oci_containerengine_node_pool" "nodepools" {
  cluster_id     = oci_containerengine_cluster.k8s_cluster.id
  compartment_id = var.compartment_id
  depends_on     = [oci_containerengine_cluster.k8s_cluster]

  kubernetes_version = local.kubernetes_version
  name               = "${var.label_prefix}-${var.node_pools.node_pool_name_prefix}-${count.index + 1}"

  node_config_details {

    dynamic "placement_configs" {
      iterator = ad_iterator
      for_each = var.ad_names
      content {
        availability_domain = ad_iterator.value
        subnet_id           = var.oke_cluster.cluster_subnets["workers"]
      }
    }
    # set quantity to a minimum of 3 per subnet for single AD region to ensure 3 fault domains
    size = max(3, element(var.node_pools.node_pools[(element(keys(var.node_pools.node_pools), count.index))], 1))
  }

  node_source_details {
    image_id    = var.node_pools.node_pool_image_id == "none" ? data.oci_core_images.latest_images[count.index].images[0].id : var.node_pools.node_pool_image_id
    source_type = "IMAGE"
  }

  # node_image_id = var.node_pools.node_pool_image_id == "none" ? data.oci_core_images.latest_images[count.index].images[0].id : var.node_pools.node_pool_image_id
  node_shape    = element(var.node_pools.node_pools[(element(keys(var.node_pools.node_pools), count.index))], 0)

  ssh_public_key = file(var.oke_ssh_keys.ssh_public_key_path)

  # initial_node_labels {
  #   key   = "key"
  #   value = "value"
  # }

  count = length(var.node_pools.node_pools)
}

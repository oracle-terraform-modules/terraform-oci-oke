# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_containerengine_node_pool" "nodepools_topology1" {
  cluster_id     = oci_containerengine_cluster.k8s_cluster.id
  compartment_id = var.oke_identity.compartment_ocid
  depends_on     = ["oci_containerengine_cluster.k8s_cluster"]

  # initial_node_labels {
  #   key   = "key"
  #   value = "value"
  # }

  kubernetes_version  = local.kubernetes_version
  name                = "${var.oke_general.label_prefix}-${var.node_pools.node_pool_name_prefix}-${count.index + 1}"
  node_image_id       = data.oci_core_images.latest_images.images[0].id
  node_shape          = var.node_pools.node_pool_node_shape

  # set quanity to a minimum of 2 per subnet for single AD region to ensure adequate number of fault domains
  quantity_per_subnet = max(2, var.node_pools.node_pool_quantity_per_subnet)
  ssh_public_key      = file(var.oke_ssh_keys.ssh_public_key_path)

  subnet_ids = [var.oke_cluster.cluster_subnets["workers_ad1"]]

  count      = length(var.oke_general.ad_names) == 1 ? var.node_pools.node_pools : 0
}

resource "oci_containerengine_node_pool" "nodepools_topology2" {
  cluster_id     = oci_containerengine_cluster.k8s_cluster.id
  compartment_id = var.oke_identity.compartment_ocid
  depends_on     = ["oci_containerengine_cluster.k8s_cluster"]

  # initial_node_labels {
  #   key   = "key"
  #   value = "value"
  # }

  kubernetes_version  = local.kubernetes_version
  name                = "${var.oke_general.label_prefix}-${var.node_pools.node_pool_name_prefix}-${count.index + 1}"
  node_image_id       = data.oci_core_images.latest_images.images[0].id
  node_shape          = var.node_pools.node_pool_node_shape
  quantity_per_subnet = var.node_pools.node_pool_quantity_per_subnet
  ssh_public_key      = file(var.oke_ssh_keys.ssh_public_key_path)

  # credit: Stephen Cross
  subnet_ids = ["${var.oke_cluster.cluster_subnets["workers_ad${count.index + 1}"]}", "${var.oke_cluster.cluster_subnets["workers_ad${((count.index + 1) % 3) + 1}"]}"]

  count = length(var.oke_general.ad_names) == 3 && var.node_pools.nodepool_topology == 2 ? var.node_pools.node_pools : 0
}

resource "oci_containerengine_node_pool" "nodepools_topology3" {
  cluster_id     = oci_containerengine_cluster.k8s_cluster.id
  compartment_id = var.oke_identity.compartment_ocid
  depends_on     = ["oci_containerengine_cluster.k8s_cluster"]

  kubernetes_version  = local.kubernetes_version
  name                = "${var.oke_general.label_prefix}-${var.node_pools.node_pool_name_prefix}-${count.index + 1}"
  node_image_id       = var.node_pools.node_pool_image_id == "NONE" ? data.oci_core_images.latest_images.images[0].id : var.node_pools.node_pool_image_id
  node_shape          = var.node_pools.node_pool_node_shape
  quantity_per_subnet = var.node_pools.node_pool_quantity_per_subnet
  subnet_ids          = [var.oke_cluster.cluster_subnets["workers_ad1"], var.oke_cluster.cluster_subnets["workers_ad2"], var.oke_cluster.cluster_subnets["workers_ad3"]]
  ssh_public_key      = file(var.oke_ssh_keys.ssh_public_key_path)

  # initial_node_labels {
  #   key   = "key"
  #   value = "value"
  # }

  count = length(var.oke_general.ad_names) == 3 && var.node_pools.nodepool_topology == 3 ? var.node_pools.node_pools : 0
}

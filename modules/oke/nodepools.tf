# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_containerengine_node_pool" "nodepools_topology1" {
  cluster_id     = oci_containerengine_cluster.k8s_cluster.id
  compartment_id = var.compartment_ocid
  depends_on     = ["oci_containerengine_cluster.k8s_cluster"]

  # initial_node_labels {
  #   key   = "key"
  #   value = "value"
  # }

  kubernetes_version  = local.kubernetes_version
  name                = "${var.label_prefix}-${var.node_pool_name_prefix}-${count.index + 1}"
  node_image_id       = data.oci_core_images.latest_images.images[0].id
  node_shape          = var.node_pool_node_shape
  #quanity per subnet will be minimum 2 for single AD region
  quantity_per_subnet = max(2, var.node_pool_quantity_per_subnet)
  ssh_public_key      = file(var.ssh_public_key_path)

  subnet_ids = [var.cluster_subnets["workers_ad1"]]
  # count to check single AD region
  count      = length(var.ad_names) == 1 ? var.node_pools : 0
}

resource "oci_containerengine_node_pool" "nodepools_topology2" {
  cluster_id     = oci_containerengine_cluster.k8s_cluster.id
  compartment_id = var.compartment_ocid
  depends_on     = ["oci_containerengine_cluster.k8s_cluster"]

  # initial_node_labels {
  #   key   = "key"
  #   value = "value"
  # }

  kubernetes_version  = local.kubernetes_version
  name                = "${var.label_prefix}-${var.node_pool_name_prefix}-${count.index + 1}"
  node_image_id       = data.oci_core_images.latest_images.images[0].id
  node_shape          = var.node_pool_node_shape
  quantity_per_subnet = var.node_pool_quantity_per_subnet
  ssh_public_key      = file(var.ssh_public_key_path)

  # credit: Stephen Cross
  subnet_ids = ["${var.cluster_subnets["workers_ad${count.index + 1}"]}", "${var.cluster_subnets["workers_ad${((count.index + 1) % 3) + 1}"]}"]

  count = var.nodepool_topology == 2 ? var.node_pools : 0
}

resource "oci_containerengine_node_pool" "nodepools_topology3" {
  cluster_id     = oci_containerengine_cluster.k8s_cluster.id
  compartment_id = var.compartment_ocid
  depends_on     = ["oci_containerengine_cluster.k8s_cluster"]

  kubernetes_version  = local.kubernetes_version
  name                = "${var.label_prefix}-${var.node_pool_name_prefix}-${count.index + 1}"
  node_image_id       = var.node_pool_image_id == "NONE" ? data.oci_core_images.latest_images.images[0].id : var.node_pool_image_id
  node_shape          = var.node_pool_node_shape
  quantity_per_subnet = var.node_pool_quantity_per_subnet
  subnet_ids          = [var.cluster_subnets["workers_ad1"], var.cluster_subnets["workers_ad2"], var.cluster_subnets["workers_ad3"]]
  ssh_public_key      = file(var.ssh_public_key_path)

  # initial_node_labels {
  #   key   = "key"
  #   value = "value"
  # }
  #count to check three AD region
  count = length(var.ad_names) == 3 ? var.node_pools : 0
}

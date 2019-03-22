# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_containerengine_node_pool" "nodepools_topology2" {
  depends_on         = ["oci_containerengine_cluster.k8s_cluster"]
  cluster_id         = "${oci_containerengine_cluster.k8s_cluster.id}"
  compartment_id     = "${var.compartment_ocid}"
  kubernetes_version = "${var.cluster_kubernetes_version}"
  name               = "${var.label_prefix}-${var.node_pool_name_prefix}-${count.index+1}"
  node_image_name    = "${var.node_pool_node_image_name}"
  node_shape         = "${var.node_pool_node_shape}"
  
  # credit: Stephen Cross
  subnet_ids = ["${var.cluster_subnets["workers_ad${count.index+1}"]}", "${var.cluster_subnets["workers_ad${((count.index+1)%3)+1}"]}"]

  # initial_node_labels {
  #   key   = "key"
  #   value = "value"
  # }

  quantity_per_subnet = "${var.node_pool_quantity_per_subnet}"
  ssh_public_key      = "${file(var.ssh_public_key_path)}"
  count               = "${(var.nodepool_topology == "2") ? var.node_pools : 0}"
}

resource "oci_containerengine_node_pool" "nodepools_topology3" {
  depends_on         = ["oci_containerengine_cluster.k8s_cluster"]
  cluster_id         = "${oci_containerengine_cluster.k8s_cluster.id}"
  compartment_id     = "${var.compartment_ocid}"
  kubernetes_version = "${var.cluster_kubernetes_version}"
  name               = "${var.label_prefix}-${var.node_pool_name_prefix}-${count.index+1}"
  node_image_name    = "${var.node_pool_node_image_name}"
  node_shape         = "${var.node_pool_node_shape}"
  subnet_ids         = ["${var.cluster_subnets["workers_ad1"]}", "${var.cluster_subnets["workers_ad2"]}", "${var.cluster_subnets["workers_ad3"]}"]

  # initial_node_labels {
  #   key   = "key"
  #   value = "value"
  # }

  quantity_per_subnet = "${var.node_pool_quantity_per_subnet}"
  ssh_public_key      = "${file(var.ssh_public_key_path)}"
  count               = "${(var.nodepool_topology == "3") ? var.node_pools: 0}"
}

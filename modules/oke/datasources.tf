# Copyright (c) 2017, 2022 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

data "oci_identity_availability_domains" "ad_list" {
  compartment_id = var.compartment_id
}

data "oci_containerengine_node_pool_option" "node_pool_options" {
  compartment_id      = var.compartment_id
  node_pool_option_id = oci_containerengine_cluster.k8s_cluster.id
}

# get the list of node pools for the cluster
data "oci_containerengine_node_pools" "nodepools" {
  compartment_id = var.compartment_id

  cluster_id = oci_containerengine_cluster.k8s_cluster.id

  filter {
    name   = "name"
    values = ["${var.label_prefix}*"]
    regex  = true
  }

  depends_on = [
    oci_containerengine_node_pool.nodepools,
    oci_containerengine_node_pool.autoscaler_pool
  ]
}

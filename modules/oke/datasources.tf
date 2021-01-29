# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

data "oci_containerengine_node_pools" "all_node_pools" {
  compartment_id = var.compartment_id
  cluster_id     = oci_containerengine_cluster.k8s_cluster.id
  depends_on     = [oci_containerengine_node_pool.nodepools]
}

data "oci_containerengine_node_pool_option" "node_pool_options" {
  node_pool_option_id = oci_containerengine_cluster.k8s_cluster.id
}

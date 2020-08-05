# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

data "oci_core_images" "latest_images" {
  for_each                 = var.node_pools.node_pools
  compartment_id           = var.compartment_id
  operating_system         = var.node_pools.node_pool_os
  operating_system_version = var.node_pools.node_pool_os_version
  shape                    = element(each.value, 0)
  sort_by                  = "TIMECREATED"
}

data "oci_containerengine_cluster_option" "k8s_cluster_option" {
  cluster_option_id = "all"
}

data "oci_containerengine_node_pools" "all_node_pools" {
  compartment_id = var.compartment_id
  cluster_id     = oci_containerengine_cluster.k8s_cluster.id
  depends_on     = [oci_containerengine_node_pool.nodepools]
}

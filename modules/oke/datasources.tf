# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

data "oci_core_images" "latest_images" {
  compartment_id           = var.oke_identity.compartment_id
  operating_system         = var.node_pools.node_pool_os
  operating_system_version = var.node_pools.node_pool_os_version
  shape                    = element(var.node_pools.node_pools[(element(keys(var.node_pools.node_pools), count.index))], 0)
  sort_by                  = "TIMECREATED"
  count                    = length(var.node_pools.node_pools)
}

data "oci_containerengine_cluster_option" "k8s_cluster_option" {
  #Required
  cluster_option_id = "all"
}

data "oci_containerengine_node_pools" "all_node_pools" {
  compartment_id = var.oke_identity.compartment_id
  cluster_id     = oci_containerengine_cluster.k8s_cluster.id
  depends_on     = ["oci_containerengine_node_pool.nodepools"]
}

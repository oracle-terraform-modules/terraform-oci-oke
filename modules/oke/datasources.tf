# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

data "oci_core_images" "latest_images" {
  compartment_id           = var.oke_identity.compartment_ocid
  operating_system         = var.node_pools.node_pool_os
  operating_system_version = var.node_pools.node_pool_os_version
  shape                    = var.node_pools.node_pool_shape["nodepool${count.index + 1}"]
  sort_by                  = "TIMECREATED"
  count                    = var.node_pools.node_pools
}

data "oci_containerengine_cluster_option" "k8s_cluster_option" {
  #Required
  cluster_option_id = "all"
}

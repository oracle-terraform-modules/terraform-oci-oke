# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

output "cluster_id" {
  value = oci_containerengine_cluster.k8s_cluster.id
}

output "nodepool_ids" {
  value = zipmap(values(oci_containerengine_node_pool.nodepools)[*].name, values(oci_containerengine_node_pool.nodepools)[*].id)
}

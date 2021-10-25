# Copyright 2017, 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

output "cluster_id" {
  value = oci_containerengine_cluster.k8s_cluster.id
}

output "kms_dynamic_group_id" {
  value = var.use_encryption == true ? oci_identity_dynamic_group.oke_kms_cluster[0].id : "null"
}

output "nodepool_ids" {
  value = zipmap(values(oci_containerengine_node_pool.nodepools)[*].name, values(oci_containerengine_node_pool.nodepools)[*].id)
}

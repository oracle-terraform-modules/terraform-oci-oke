# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

output "apiserver_private_endpoint" {
  description = "OKE cluster apiserver private IP address"
  value       = local.apiserver_private_endpoint
}

output "cluster_id" {
  value = oci_containerengine_cluster.k8s_cluster.id
}

output "cluster_kms_dynamic_group_id" {
  value = var.use_cluster_encryption == true && var.create_policies ? oci_identity_dynamic_group.oke_kms_cluster[0].id : "null"
}

output "expected_node_count" {
  description = "# of nodes expected from configured node pools"
  value       = local.expected_node_count
}

output "nodepool_ids" {
  value = zipmap(values(oci_containerengine_node_pool.nodepools)[*].name, values(oci_containerengine_node_pool.nodepools)[*].id)
}

output "endpoints" {
  value = oci_containerengine_cluster.k8s_cluster.endpoints
}

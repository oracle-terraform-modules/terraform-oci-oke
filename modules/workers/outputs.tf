# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

output "worker_pools" {
  description = "Enabled worker pools"
  value       = local.enabled_worker_pools_out
}

output "worker_pool_ids" {
  description = "Enabled worker pool IDs"
  value       = local.worker_pool_ids
}

output "worker_count_expected" {
  description = "# of nodes expected from enabled worker pools"
  value       = local.expected_node_count
}

output "worker_node_pools" {
  description = "OKE-managed Node Pools"
  value       = local.worker_node_pools
}

output "worker_instance_pools" {
  description = "Self-managed Instance Pools"
  value       = local.worker_instance_pools
}

output "worker_cluster_networks" {
  description = "Self-managed Cluster Networks"
  value       = local.worker_cluster_networks
}

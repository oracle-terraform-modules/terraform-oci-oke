# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

output "worker_pools" {
  description = "Created worker pools (mode != 'instance')"
  value       = local.worker_pools_output
}

output "worker_instances" {
  description = "Created worker pools (mode == 'instance')"
  value       = local.worker_instances
}

output "worker_pool_ids" {
  description = "Created worker pool IDs"
  value       = local.worker_pool_ids
}

output "worker_pool_ips" {
  description = "Created worker instance private IPs by pool for available modes ('node-pool', 'instance')."
  value       = local.worker_pool_ips
}

output "worker_count_expected" {
  description = "# of nodes expected from created worker pools"
  value       = local.expected_node_count
}

output "worker_drain_expected" {
  description = "# of nodes expected to be draining in worker pools"
  value       = local.expected_drain_count
}

output "worker_pool_autoscale_expected" {
  description = "# of worker pools expected with autoscale enabled from created worker pools"
  value       = local.expected_autoscale_worker_pools
}
# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

output "worker_pools" {
  description = "Created worker pools"
  value       = local.worker_pools_output
}

output "worker_pool_ids" {
  description = "Created worker pool IDs"
  value       = local.worker_pool_ids
}

output "worker_count_expected" {
  description = "# of nodes expected from created worker pools"
  value       = local.expected_node_count
}

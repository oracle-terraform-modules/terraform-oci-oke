# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

output "worker_availability_domains" {
  description = "Worker availability domains"
  value       = local.ad_number_to_name
}

output "worker_pools_enabled" {
  description = "Worker pools enabled in configuration"
  value       = local.worker_pools_enabled_out
}

output "worker_pools_active" {
  description = "Worker pools provisioned in Terraform state"
  value       = local.worker_pools_active
}

output "expected_node_count" {
  description = "# of nodes expected from enabled worker pools"
  value       = local.expected_node_count
}

output "worker_pool_ids" {
  description = "OKE worker pool OCIDs"
  value       = { for k, v in local.worker_pools_active : k => v.id }
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

output "np_options" {
  description = "OKE node pool options"
  value       = data.oci_containerengine_node_pool_option.np_options
}

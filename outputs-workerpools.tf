# Copyright 2022, 2023 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

output "cloudinit_node_pool" {
  description = "Node pool cloud-init (when debug_mode==true)"
  value       = var.debug_mode ? module.worker_pools.cloudinit_node_pool : null
}

output "cloudinit_instance_pool" {
  description = "Instance pool cloud-init (when debug_mode==true)"
  value       = var.debug_mode ? module.worker_pools.cloudinit_instance_pool : null
}

output "worker_pools_enabled" {
  description = "Desired worker pool state to be applied"
  value       = length(module.worker_pools.worker_pools_enabled) > 0 ? module.worker_pools.worker_pools_enabled : null
}

output "worker_pool_ids" {
  description = "All active worker pool OCIDs"
  value       = length(module.worker_pools.worker_pool_ids) > 0 ? module.worker_pools.worker_pool_ids : null
}

output "worker_availability_domains" {
  description = "All worker pool ADs"
  value       = length(module.worker_pools.worker_pool_ids) > 0 ? module.worker_pools.worker_availability_domains : null
}

output "worker_np_options" {
  description = "OKE node pool options (when debug_mode==true)"
  value       = var.debug_mode ? (length(module.worker_pools.np_options) > 0 ? module.worker_pools.np_options : null) : null
}

output "worker_kubeconfig" {
  description = "OKE kubeconfig (when debug_mode==true)"
  value       = var.debug_mode ? (length(module.worker_pools.kubeconfig) > 0 ? module.worker_pools.kubeconfig : null) : null
}

output "worker_cluster_ca_cert" {
  description = "OKE cluster CA certificate (when debug_mode==true)"
  value       = var.debug_mode ? (length(module.worker_pools.cluster_ca_cert) > 0 ? module.worker_pools.cluster_ca_cert : null) : null
}

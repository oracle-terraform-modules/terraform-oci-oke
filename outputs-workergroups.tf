# Copyright 2022 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

output "cloudinit_node_pool" {
  description = "Node pool cloud-init (when debug_mode==true)"
  value       = var.debug_mode ? module.workergroup.cloudinit_node_pool : null
}

output "cloudinit_instance_pool" {
  description = "Instance pool cloud-init (when debug_mode==true)"
  value       = var.debug_mode ? module.workergroup.cloudinit_instance_pool : null
}

output "worker_groups_enabled" {
  description = "Desired worker group state to be applied"
  value       = length(module.workergroup.worker_groups_enabled) > 0 ? module.workergroup.worker_groups_enabled : null
}

output "worker_groups_active" {
  description = "Active worker groups"
  value       = length(module.workergroup.worker_groups_active) > 0 ? module.workergroup.worker_groups_active : null
}

output "worker_group_ids" {
  description = "All worker group OCIDs"
  value       = length(module.workergroup.worker_group_ids) > 0 ? module.workergroup.worker_group_ids : null
}

output "worker_availability_domains" {
  description = "All worker group ADs"
  value       = length(module.workergroup.worker_availability_domains) > 0 ? module.workergroup.worker_availability_domains : null
}

output "worker_np_options" {
  description = "OKE node pool options (when debug_mode==true)"
  value       = var.debug_mode ? (length(module.workergroup.np_options) > 0 ? module.workergroup.np_options : null) : null
}

output "worker_kubeconfig" {
  description = "OKE kubeconfig (when debug_mode==true)"
  value       = var.debug_mode ? (length(module.workergroup.kubeconfig) > 0 ? module.workergroup.kubeconfig : null) : null
}

output "worker_cluster_ca_cert" {
  description = "OKE cluster CA certificate (when debug_mode==true)"
  value       = var.debug_mode ? (length(module.workergroup.cluster_ca_cert) > 0 ? module.workergroup.cluster_ca_cert : null) : null
}
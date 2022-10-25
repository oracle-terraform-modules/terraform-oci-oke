# Copyright 2022, Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

output "cloudinit_node_pool" {
  description = "Node pool worker cloud-init"
  value       = data.cloudinit_config.worker_np.rendered
}

output "cloudinit_instance_pool" {
  description = "Instance pool worker cloud-init"
  value       = data.cloudinit_config.worker_ip.rendered
}

output "worker_availability_domains" {
  description = "Worker availability domains"
  value       = local.ad_number_to_name
}

output "enabled_worker_groups" {
  description = "Enabled worker groups"
  value       = local.enabled_worker_groups
}

output "worker_groups_active" {
  description = "OKE cluster CA certificate"
  value       = local.result_groups_output
}

output "worker_group_ids" {
  description = "OKE worker group OCIDs"
  value       = local.worker_groups_ids
}

output "np_options" {
  description = "OKE node pool options"
  value       = data.oci_containerengine_node_pool_option.np_options
}

output "kubeconfig" {
  description = "OKE cluster kubeconfig"
  value       = data.oci_containerengine_cluster_kube_config.kube_config
}

output "cluster_ca_cert" {
  description = "OKE cluster CA certificate"
  value       = local.kubeconfig_ca_cert
}
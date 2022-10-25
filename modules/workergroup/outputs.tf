# Copyright (c) 2022 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

output "cloudinit" {
  description = "Worker cloud-init"
  value       = data.cloudinit_config.worker_per_boot.rendered
}

output "worker_availability_domains" {
  description = "Worker availability domains"
  value       = local.ad_number_to_name
}

output "worker_groups_enabled" {
  description = "Worker groups enabled in configuration"
  value       = local.worker_groups_enabled
}

output "worker_groups_active" {
  description = "Worker groups provisioned in Terraform state"
  value       = local.worker_groups_active
}

output "expected_node_count" {
  description = "# of nodes expected from enabled worker groups"
  value       = local.expected_node_count
}

output "worker_group_ids" {
  description = "OKE worker group OCIDs"
  value       = tomap({ for k, v in local.worker_groups_active : k => v.id })
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
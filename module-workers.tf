# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  worker_count_expected = coalesce(one(module.workers[*].worker_count_expected), 0)
  worker_drain_expected = coalesce(one(module.workers[*].worker_drain_expected), 0)

  # Distinct list of compartments for enabled worker pools
  worker_compartments = distinct(compact([
    for k, v in var.worker_pools : lookup(v, "compartment_id", local.compartment_id)
    if tobool(lookup(v, "create", true))
  ]))

  # Worker pools with cluster autoscaler management enabled
  autoscaler_compartments = distinct(compact([
    for k, v in var.worker_pools : lookup(v, "compartment_id", local.compartment_id)
    if tobool(lookup(v, "create", true)) && tobool(lookup(v, "allow_autoscaler", false))
  ]))
}

# Default workers sub-module implementation for OKE cluster
module "workers" {
  count  = local.cluster_enabled ? 1 : 0
  source = "./modules/workers"

  # Common
  compartment_id      = local.worker_compartment_id
  tenancy_id          = local.tenancy_id
  state_id            = local.state_id
  ad_numbers          = local.ad_numbers
  ad_numbers_to_names = local.ad_numbers_to_names

  # Cluster
  apiserver_private_host = local.apiserver_private_host
  cluster_ca_cert        = local.cluster_ca_cert
  cluster_dns            = var.cluster_dns
  cluster_id             = coalesce(var.cluster_id, one(module.cluster[*].cluster_id))
  cluster_type           = var.cluster_type
  kubernetes_version     = var.kubernetes_version

  # Compute clusters
  compute_clusters = var.worker_compute_clusters

  # Worker pools
  worker_pool_mode = var.worker_pool_mode
  worker_pool_size = var.worker_pool_size
  worker_pools     = var.worker_pools

  # Workers
  assign_dns                 = var.assign_dns
  assign_public_ip           = var.worker_is_public
  block_volume_type          = var.worker_block_volume_type
  capacity_reservation_id    = var.worker_capacity_reservation_id
  cloud_init                 = var.worker_cloud_init
  disable_default_cloud_init = var.worker_disable_default_cloud_init
  cni_type                   = var.cni_type
  image_id                   = var.worker_image_id
  image_ids                  = local.image_ids
  image_os                   = var.worker_image_os
  image_os_version           = var.worker_image_os_version
  image_type                 = var.worker_image_type
  indexed_images             = local.indexed_images
  kubeproxy_mode             = var.kubeproxy_mode
  max_pods_per_node          = var.max_pods_per_node
  node_labels                = alltrue([var.cluster_type == "basic", var.cilium_install == true]) ? merge(var.worker_node_labels, { "oci.oraclecloud.com/custom-k8s-networking" = true }) : var.worker_node_labels
  node_metadata              = var.worker_node_metadata
  agent_config               = var.agent_config
  platform_config            = var.platform_config
  pod_nsg_ids                = concat(var.pod_nsg_ids, var.cni_type == "npn" ? [try(module.network.pod_nsg_id, null)] : [])
  pod_subnet_id              = try(module.network.pod_subnet_id, "") # safe destroy; validated in submodule
  pv_transit_encryption      = var.worker_pv_transit_encryption
  shape                      = var.worker_shape
  ssh_public_key             = local.ssh_public_key
  timezone                   = var.timezone
  volume_kms_key_id          = var.worker_volume_kms_key_id
  worker_nsg_ids             = concat(var.worker_nsg_ids, [try(module.network.worker_nsg_id, null)])
  worker_subnet_id           = try(module.network.worker_subnet_id, "") # safe destroy; validated in submodule
  preemptible_config         = var.worker_preemptible_config

  # Tagging
  tag_namespace    = var.tag_namespace
  defined_tags     = local.workers_defined_tags
  freeform_tags    = local.workers_freeform_tags
  use_defined_tags = var.use_defined_tags

  depends_on = [
    module.iam,
  ]
}

output "worker_pools" {
  description = "Created worker pools (mode != 'instance')"
  value       = var.output_detail && local.worker_count_expected > 0 ? try(one(module.workers[*].worker_pools), null) : null
}

output "worker_instances" {
  description = "Created worker pools (mode == 'instance')"
  value       = var.output_detail && local.worker_count_expected > 0 ? try(one(module.workers[*].worker_instances), null) : null
}

output "worker_pool_ids" {
  description = "Enabled worker pool IDs"
  value       = local.worker_count_expected > 0 ? try(one(module.workers[*].worker_pool_ids), null) : null
}

output "worker_pool_ips" {
  description = "Created worker instance private IPs by pool for available modes ('node-pool', 'instance')."
  value       = local.worker_count_expected > 0 ? try(one(module.workers[*].worker_pool_ips), null) : null
}
# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  worker_count_expected = coalesce(one(module.workers[*].worker_count_expected), 0)

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
  count  = var.create_cluster ? 1 : 0
  source = "./modules/workers"

  # Common
  compartment_id      = local.worker_compartment_id
  tenancy_id          = local.tenancy_id
  state_id            = random_id.state_id.id
  ad_numbers          = local.ad_numbers
  ad_numbers_to_names = local.ad_numbers_to_names

  # Cluster
  apiserver_private_host = try(split(":", one(module.cluster[*].endpoints.private_endpoint))[0], "")
  cluster_ca_cert        = local.cluster_ca_cert
  cluster_dns            = var.cluster_dns
  cluster_id             = coalesce(var.cluster_id, one(module.cluster[*].cluster_id))
  kubernetes_version     = var.kubernetes_version

  # Worker pools
  worker_pool_mode = var.worker_pool_mode
  worker_pool_size = var.worker_pool_size
  worker_pools     = var.worker_pools

  # Workers
  assign_dns            = var.assign_dns
  assign_public_ip      = var.worker_type == "public"
  block_volume_type     = var.worker_block_volume_type
  cloud_init            = var.worker_cloud_init
  cni_type              = var.cni_type
  image_id              = var.worker_image_id
  image_ids             = local.image_ids
  image_os              = var.worker_image_os
  image_os_version      = var.worker_image_os_version
  image_type            = var.worker_image_type
  kubeproxy_mode        = var.kubeproxy_mode
  max_pods_per_node     = var.max_pods_per_node
  node_labels           = var.worker_node_labels
  pod_nsg_ids           = concat(var.pod_nsg_ids, var.cni_type == "npn" ? [module.network.pod_nsg_id] : [])
  pod_subnet_id         = lookup(module.network.subnet_ids, "pods", "")
  pv_transit_encryption = var.worker_pv_transit_encryption
  shape                 = var.worker_shape
  ssh_public_key        = local.ssh_public_key
  timezone              = var.timezone
  volume_kms_key_id     = var.worker_volume_kms_key_id
  worker_nsg_ids        = concat(var.worker_nsg_ids, [module.network.worker_nsg_id])
  worker_subnet_id      = lookup(module.network.subnet_ids, "workers")

  # FSS
  create_fss              = var.create_fss
  fss_availability_domain = coalesce(var.fss_availability_domain, local.ad_numbers_to_names[1])
  fss_subnet_id           = lookup(module.network.subnet_ids, "fss", lookup(module.network.subnet_ids, "workers"))
  fss_nsg_ids             = var.fss_nsg_ids
  fss_mount_path          = var.fss_mount_path
  fss_max_fs_stat_bytes   = var.fss_max_fs_stat_bytes
  fss_max_fs_stat_files   = var.fss_max_fs_stat_files

  # Tagging
  tag_namespace    = var.tag_namespace
  defined_tags     = lookup(var.defined_tags, "workers", {})
  freeform_tags    = lookup(var.freeform_tags, "workers", {})
  use_defined_tags = var.use_defined_tags

  providers = {
    oci.home = oci.home
  }

  depends_on = [
    module.iam,
  ]
}

output "worker_pools" {
  description = "Enabled worker pools"
  value       = var.output_detail && local.worker_count_expected > 0 ? one(module.workers[*].worker_pools) : null
}

output "worker_pool_ids" {
  description = "Enabled worker pool IDs"
  value       = local.worker_count_expected > 0 ? one(module.workers[*].worker_pool_ids) : null
}

output "fss_id" {
  description = "FSS ID"
  value       = var.create_fss ? one(module.workers[*].fss_id) : null
}

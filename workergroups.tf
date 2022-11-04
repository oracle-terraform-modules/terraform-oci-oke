# Copyright 2022, Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Default workergroup sub-module implementation for OKE cluster
module "workergroup" {
  source                          = "./modules/workergroup"
  config_file_profile             = var.config_file_profile
  worker_groups                   = var.worker_groups
  tenancy_id                      = local.tenancy_id
  compartment_id                  = local.worker_compartment_id
  region                          = var.region
  cluster_id                      = coalesce(var.cluster_id, module.oke.cluster_id)
  apiserver_host                  = coalesce(var.apiserver_host, try(split(":", module.oke.apiserver_private_endpoint)[0], ""))
  image_id                        = var.worker_group_image_id
  image_type                      = var.worker_group_image_type
  os                              = var.node_pool_os
  os_version                      = var.node_pool_os_version
  mode                            = var.worker_group_mode
  enabled                         = var.worker_group_enabled
  size                            = var.worker_group_size
  cloudinit                       = var.cloudinit_nodepool_common
  enable_pv_encryption_in_transit = var.enable_pv_encryption_in_transit
  cluster_ca_cert                 = var.cluster_ca_cert
  kubernetes_version              = var.kubernetes_version
  pod_nsg_ids                     = try(split(",", lookup(module.network.nsg_ids, "pods", "")), [])
  worker_nsg_ids                  = coalescelist(var.worker_nsgs, try(split(",", lookup(module.network.nsg_ids, "workers", "")), []))
  primary_subnet_id               = coalesce(var.worker_group_primary_subnet_id, lookup(module.network.subnet_ids, "workers", ""))
  ssh_public_key                  = var.ssh_public_key
  ssh_public_key_path             = var.ssh_public_key_path
  timezone                        = var.node_pool_timezone
  use_volume_encryption           = var.use_node_pool_volume_encryption
  volume_kms_key_id               = var.node_pool_volume_kms_key_id
  label_prefix                    = var.label_prefix
  defined_tags                    = lookup(lookup(var.defined_tags, "oke", {}), "node", {})
  freeform_tags                   = lookup(lookup(var.freeform_tags, "oke", {}), "node", {})
  providers = {
    oci.home = oci.home
  }
}
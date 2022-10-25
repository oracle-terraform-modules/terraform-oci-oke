# Copyright (c) 2022 Oracle Corporation and/or its affiliates.
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
  image_id                        = local.worker_image_id
  image_type                      = local.worker_image_type
  os                              = var.node_pool_os
  os_version                      = var.node_pool_os_version
  enabled                         = var.worker_group_enabled
  mode                            = var.worker_group_mode
  boot_volume_size                = var.worker_group_boot_volume_size
  memory                          = var.worker_group_memory
  ocpus                           = var.worker_group_ocpus
  shape                           = var.worker_group_shape
  size                            = var.worker_group_size
  cloudinit                       = var.cloudinit_nodepool_common
  enable_pv_encryption_in_transit = var.enable_pv_encryption_in_transit
  cluster_ca_cert                 = var.cluster_ca_cert
  kubernetes_version              = var.kubernetes_version
  pod_nsg_ids                     = try(split(",", lookup(module.network.nsg_ids, "pods", "")), [])
  worker_nsg_ids                  = coalescelist(var.worker_nsgs, try(split(",", lookup(module.network.nsg_ids, "workers", "")), []))
  assign_public_ip                = var.worker_type == "public"
  primary_subnet_id               = coalesce(var.worker_group_primary_subnet_id, lookup(module.network.subnet_ids, "workers", ""))
  sriov_num_vfs                   = var.sriov_num_vfs
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

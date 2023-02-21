# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# All configuration for workers sub-module w/ defaults

# Worker pool defaults
worker_pool_size = 0
worker_pool_mode = "node-pool" # Must be node-pool

# Worker defaults
await_node_readiness         = "none"
worker_block_volume_type     = "paravirtualized"
worker_cloud_init            = []
worker_compartment_id        = null
worker_image_id              = null
worker_image_os              = "Oracle Linux" # Ignored when worker_image_type = "custom"
worker_image_os_version      = "8"            # Ignored when worker_image_type = "custom"
worker_image_type            = "oke"          # Same for type; must be "custom" when using an image OCID
worker_node_labels           = {}
worker_nsg_ids               = []
worker_pv_transit_encryption = false # true/*false
worker_type                  = "private"
worker_volume_kms_key_id     = null

worker_shape = {
  shape            = "VM.Standard.E4.Flex",
  ocpus            = 2,  # Ignored for non-Flex shapes
  memory           = 16, # Ignored for non-Flex shapes
  boot_volume_size = 50
}

worker_pools = {}

# FSS
create_fss            = false # true/*false
fss_mount_path        = "/oke_fss"
fss_max_fs_stat_bytes = 23843202333
fss_max_fs_stat_files = 223442

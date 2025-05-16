# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

worker_image_id   = "ocid1.image..."
worker_image_type = "custom"
worker_shape      = { shape = "VM.Standard.E4.Flex", ocpus = 2, memory = 16, boot_volume_size = 50 }
worker_cloud_init = [
  {
    content      = <<-EOT
    runcmd:
    - echo "Global cloud_init using cloud-config"
    EOT
    content_type = "text/cloud-config",
  },
]

worker_pool_mode = "node-pool"
worker_pool_size = 1

worker_pools = {
  np1 = {
    mode   = "node-pool",
    size   = 1,
    shape  = "VM.Standard.E4.Flex",
    create = false
  },
  wg_np-vm-ol7 = {
    description              = "OKE-managed Node Pool with OKE Oracle Linux 7 image",
    create                   = false,
    mode                     = "node-pool",
    size                     = 1,
    size_max                 = 2,
    os                       = "Oracle Linux",
    os_version               = "7",
    autoscale                = true,
    ignore_initial_pool_size = true
  },
  wg_np-vm-ol8 = {
    description              = "OKE-managed Node Pool with OKE Oracle Linux 8 image",
    create                   = false,
    mode                     = "node-pool",
    size                     = 1,
    size_max                 = 3,
    os                       = "Oracle Linux",
    os_version               = "8",
    autoscale                = true,
    ignore_initial_pool_size = true
  },
  wg_np-vm-custom = {
    description      = "OKE-managed Node Pool with custom image",
    create           = true,
    mode             = "node-pool",
    image_type       = "custom",
    size             = 1,
    allow_autoscaler = true,
  },
  shielded_instances = {
    description = "Self-managed Shielded VM Instance",
    create      = false,
    size        = 1,
    mode        = "instance",
    shape       = "VM.Standard2.4",
    platform_config = {
      is_measured_boot_enabled           = true,
      is_secure_boot_enabled             = true,
      is_trusted_platform_module_enabled = true,
    }
  }
}

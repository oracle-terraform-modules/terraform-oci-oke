# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

worker_pool_mode = "node-pool"
worker_pool_size = 1

worker_pools = {
  oke-vm-standard = {},

  oke-vm-standard-large = {
    size             = 1,
    shape            = "VM.Standard.E4.Flex",
    ocpus            = 8,
    memory           = 128,
    boot_volume_size = 200,
    create           = false,
  },

  oke-vm-standard-ol7 = {
    description = "OKE-managed Node Pool with OKE Oracle Linux 7 image",
    size        = 1,
    os          = "Oracle Linux",
    os_version  = "7",
    create      = false,
  },

  oke-vm-standard-ol8 = {
    description = "OKE-managed Node Pool with OKE Oracle Linux 8 image",
    size        = 1,
    os          = "Oracle Linux",
    os_version  = "8",
  },

  oke-vm-standard-custom = {
    description = "OKE-managed Node Pool with custom image",
    image_type  = "custom",
    image_id    = "ocid1.image...",
    size        = 1,
    create      = false,
  },
}

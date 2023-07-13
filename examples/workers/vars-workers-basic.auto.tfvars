# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

worker_pool_mode = "node-pool"
worker_pool_size = 1

worker_pools = {
  oke-vm-standard = {},

  oke-vm-standard-large = {
    description      = "OKE-managed Node Pool with OKE Oracle Linux 8 image",
    shape            = "VM.Standard.E4.Flex",
    create           = true,
    ocpus            = 8,
    memory           = 128,
    boot_volume_size = 200,
    os               = "Oracle Linux",
    os_version       = "8",
  },
}

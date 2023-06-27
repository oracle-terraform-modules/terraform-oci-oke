# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

worker_pool_mode = "node-pool"
worker_pool_size = 1

worker_pools = {
  oke-vm-active = {
    description = "Node pool with active workers", size = 2,
  },
  oke-vm-draining = {
    description = "Node pool with scheduling disabled and draining",
    drain       = true,
  },
  oke-vm-disabled = {
    description = "Node pool with resource creation disabled (destroyed)",
    create      = false,
  },
}

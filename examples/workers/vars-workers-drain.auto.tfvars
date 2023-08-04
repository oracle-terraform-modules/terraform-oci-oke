# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

worker_pool_mode = "node-pool"
worker_pool_size = 1

# Configuration for draining nodes through operator
worker_drain_ignore_daemonsets = true
worker_drain_delete_local_data = true
worker_drain_timeout_seconds   = 900

worker_pools = {
  oke-vm-active = {
    description = "Node pool with active workers",
    size        = 2,
  },
  oke-vm-draining = {
    description = "Node pool with scheduling disabled and draining through operator",
    drain       = true,
  },
  oke-vm-disabled = {
    description = "Node pool with resource creation disabled (destroyed)",
    create      = false,
  },
  oke-managed-drain = {
    description                          = "Node pool with custom settings for managed cordon & drain",
    eviction_grace_duration              = 30, # specified in seconds
    is_force_delete_after_grace_duration = true
  },
}

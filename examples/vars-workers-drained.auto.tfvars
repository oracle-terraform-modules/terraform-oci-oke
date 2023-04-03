# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Example worker pool configurations with cordoned/drained workloads

worker_pools = {
  np-active = {
    description = "Node pool with active workers",
  },
  np-draining = {
    description = "Node pool with scheduling disabled and draining",
    drain       = true,
  },
  np-disabled = {
    description = "Node pool with resource creation disabled (destroyed)",
    create      = false,
  },
}

# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Example worker pool node-cycle configuration.

worker_pools = {
  cycled-node-pool = {
    description                  = "Cycling nodes in a node_pool.",
    size                         = 4,
    node_cycling_enabled         = true
    node_cycling_max_surge       = "25%"
    node_cycling_max_unavailable = 0
    node_cycling_mode            = ["instance"] # An alternative value is boot_volume. Only a single mode is supported.
  }
}

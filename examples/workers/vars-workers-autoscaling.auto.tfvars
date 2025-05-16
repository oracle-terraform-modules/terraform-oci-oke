# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Example worker pool configurations with cluster autoscaler

worker_pools = {
  np-autoscaled = {
    description              = "Node pool managed by cluster autoscaler",
    size                     = 2,
    min_size                 = 1,
    max_size                 = 3,
    autoscale                = true,
    ignore_initial_pool_size = true
  },
  np-autoscaler = {
    description      = "Node pool with cluster autoscaler scheduling allowed",
    size             = 1,
    allow_autoscaler = true,
  },
}

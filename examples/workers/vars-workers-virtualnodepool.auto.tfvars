# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

worker_pools = {
  oke-virtual = {
    description = "OKE-managed Virtual Node Pool",
    mode        = "virtual-node-pool", size = 1,
    create      = false,
  },
}

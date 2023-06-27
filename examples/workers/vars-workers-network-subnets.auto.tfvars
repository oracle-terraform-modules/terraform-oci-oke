# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

worker_pool_mode = "node-pool"
worker_pool_size = 1

worker_subnet_id = "ocid1.subnet..."

worker_pools = {
  oke-vm-custom-subnet-flannel = {
    subnet_id = "ocid1.subnet..."
  },

  oke-vm-custom-subnet-npn = {
    subnet_id     = "ocid1.subnet..."
    pod_subnet_id = "ocid1.subnet..." // when cni_type = "npn"
  },
}

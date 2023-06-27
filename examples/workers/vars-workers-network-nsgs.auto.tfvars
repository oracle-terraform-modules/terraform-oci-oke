# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

worker_pool_mode = "node-pool"
worker_pool_size = 1

worker_nsg_ids = ["ocid1.networksecuritygroup..."]
pod_nsg_ids    = [] // when cni_type = "npn"

worker_pools = {
  oke-vm-custom-nsgs-flannel = {
    nsg_ids = ["ocid1.networksecuritygroup..."]
  },

  oke-vm-custom-nsgs-npn = {
    nsg_ids     = ["ocid1.networksecuritygroup..."]
    pod_nsg_ids = ["ocid1.networksecuritygroup..."] // when cni_type = "npn"
  },
}

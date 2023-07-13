# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

worker_pool_mode = "node-pool"
worker_pool_size = 1

kubeproxy_mode    = "iptables" // *iptables/ipvs
worker_is_public  = false
assign_public_ip  = false
worker_nsg_ids    = ["ocid1.networksecuritygroup..."]
worker_subnet_id  = "ocid1.subnet..."
max_pods_per_node = 110
pod_nsg_ids       = [] // when cni_type = "npn"

worker_pools = {
  oke-vm-custom-network-flannel = {
    assign_public_ip = false,
    create           = false,
    subnet_id        = "ocid1.subnet..."
    nsg_ids          = ["ocid1.networksecuritygroup..."]
  },

  oke-vm-custom-network-npn = {
    assign_public_ip = false,
    create           = false,
    subnet_id        = "ocid1.subnet..."
    pod_subnet_id    = "ocid1.subnet..."
    nsg_ids          = ["ocid1.networksecuritygroup..."]
    pod_nsg_ids      = ["ocid1.networksecuritygroup..."]
  },

  oke-vm-vnics = {
    mode   = "instance-pool",
    size   = 1,
    create = false,
    secondary_vnics = {
      vnic0 = {
        nic_index = 0,
        subnet_id = "ocid1.subnet..."
      },
      vnic1 = {
        nic_index = 1,
        subnet_id = "ocid1.subnet..."
      },
    },
  },

  oke-bm-vnics = {
    mode          = "cluster-network",
    size          = 2,
    shape         = "BM.GPU.B4.8",
    placement_ads = [1],
    create        = false,
    secondary_vnics = {
      gpu0 = {
        nic_index = 0,
        subnet_id = "ocid1.subnet..."
      },
      gpu1 = {
        nic_index = 1,
        subnet_id = "ocid1.subnet..."
      },
    },
  },
}

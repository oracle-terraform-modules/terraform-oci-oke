# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

worker_compute_clusters = {
  "shared" = {
    placement_ad = 1
  }
}

worker_pools = {
  oke-bm-rdma = {
    description      = "Self-managed nodes in a Compute Cluster with RDMA networking"
    mode             = "compute-cluster",
    compute_cluster  = "shared"
    placement_ad     = "1"
    instance_ids     = ["1", "2", "3"],
    shape            = "BM.HPC2.36",
    boot_volume_size = 50,
  },

  oke-bm-gpu-rdma = {
    description      = "Self-managed GPU nodes in a Compute Cluster with RDMA networking"
    mode             = "cluster-network",
    compute_cluster  = "shared"
    placement_ad     = "1",
    instance_ids     = ["1", "2"],
    shape            = "BM.GPU4.8",
    image_id         = "ocid1.image..."
    image_type       = "custom"
    boot_volume_size = 50,
  }
}

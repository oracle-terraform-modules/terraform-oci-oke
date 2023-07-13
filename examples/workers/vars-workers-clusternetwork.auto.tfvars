# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

worker_pools = {
  oke-vm-standard = {
    description      = "Managed node pool for operational workloads without GPU toleration"
    mode             = "node-pool",
    size             = 1,
    shape            = "VM.Standard.E4.Flex",
    ocpus            = 2,
    memory           = 16,
    boot_volume_size = 50,
  },

  oke-bm-gpu-rdma = {
    description   = "Self-managed nodes in a Cluster Network with RDMA networking",
    mode          = "cluster-network",
    size          = 1,
    shape         = "BM.GPU.B4.8",
    placement_ads = [1],
    image_id      = "ocid1.image..."
    cloud_init = [
      {
        content = <<-EOT
        #!/usr/bin/env bash
        echo "Pool-specific cloud_init using shell script"
        EOT
      },
    ],
    secondary_vnics = {
      "vnic-display-name" = {
        nic_index = 1,
        subnet_id = "ocid1.subnet..."
      },
    },
  }
}

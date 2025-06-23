# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

worker_pools = {
  oke-vm-instance-pool = {
    description = "Self-managed Instance Pool with custom image",
    mode        = "instance-pool",
    size        = 1,
    node_labels = {
      "keya" = "valuea",
      "keyb" = "valueb"
    },
    secondary_vnics = {
      "vnic-display-name" = {},
    },
  },
  oke-vm-instance-pool-burst = {
    description = "Self-managed Instance Pool With Bursting",
    mode        = "instance-pool",
    size        = 1,
    burst       = "BASELINE_1_8", # Valid values BASELINE_1_8,BASELINE_1_2
  },
  oke-vm-instance-pool-with-block-volume = {
    description              = "Self-managed Instance Pool with block volume",
    mode                     = "instance-pool",
    size                     = 1,
    disable_block_volume     = false,
    block_volume_size_in_gbs = 60,
  },
  oke-vm-instance-pool-without-block-volume = {
    description          = "Self-managed Instance Pool without block volume",
    mode                 = "instance-pool",
    size                 = 1,
    disable_block_volume = true,
  },
  oke-vm-instance-pool-taints = {
    description = "Self-managed Instance Pool with taints",
    mode        = "instance-pool",
    size        = 1,
    node_labels = {
      "keya" = "valuea",
      "keyb" = "valueb"
    },
    taints = {
      env = {
        value = "dev"
        effect = "NoSchedule"
      },
      "oke.oraclecloud.com/pool.name" = {
        value = "oke-vm-instance-multi-taint"
        effect = "NoSchedule"
      }
    }
  },
}

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
}

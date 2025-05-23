# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

worker_pools = {
  oke-vm-instance = {
    description = "Self-managed Instances",
    mode        = "instance",
    size        = 1,
    node_labels = {
      "keya" = "valuea",
      "keyb" = "valueb"
    },
    secondary_vnics = {
      "vnic-display-name" = {},
    },
  },
  oke-vm-instance-burst = {
    description = "Self-managed Instance With Bursting",
    mode        = "instance",
    size        = 1,
    burst       = "BASELINE_1_8", # Valid values BASELINE_1_8,BASELINE_1_2
  },
}

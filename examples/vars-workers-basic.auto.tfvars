# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Example worker pool configurations

worker_pools = {
  np-vm-ol7 = {
    description = "OKE-managed Node Pool with OKE Oracle Linux 7 image",
    mode        = "node-pool", size = 1, size_max = 2, os = "Oracle Linux", os_version = "7", autoscale = true,
  },
  np-vm-ol8 = {
    description = "OKE-managed Node Pool with OKE Oracle Linux 8 image",
    mode        = "node-pool", size = 1, size_max = 3, os = "Oracle Linux", os_version = "8", autoscale = true,
  },
  np-vm-custom = {
    description = "OKE-managed Node Pool with custom image",
    mode        = "node-pool", image_type = "custom", size = 1, allow_autoscaler = true,
  },
}

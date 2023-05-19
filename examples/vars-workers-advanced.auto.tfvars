# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

worker_image_id   = "ocid1.image..."
worker_image_type = "custom"
worker_shape      = { shape = "VM.Standard.E4.Flex", ocpus = 2, memory = 16, boot_volume_size = 50 }
worker_cloud_init = [
  {
    content      = <<-EOT
    runcmd:
    - echo "Global cloud_init using cloud-config"
    EOT
    content_type = "text/cloud-config",
  },
]

worker_pools = {
  np1 = { mode = "node-pool", size = 1, shape = "VM.Standard.E4.Flex", create = false },
  wg1 = {
    description = "Self-managed Cluster Network", create = false,
    mode        = "cluster-network", size = 1, shape = "BM.GPU.B4.8", placement_ads = [1],
    cloud_init = [
      {
        content = <<-EOT
        #!/usr/bin/env bash
        echo "Pool-specific cloud_init using shell script"
        EOT
      },
    ],
    secondary_vnics = {
      "vnic-display-name" = { nic_index = 1, subnet_id = "ocid1.subnet..." },
    },
  },
  wg_np-vm-ol7 = {
    description = "OKE-managed Node Pool with OKE Oracle Linux 7 image", create = false,
    mode        = "node-pool", size = 1, size_max = 2, os = "Oracle Linux", os_version = "7", autoscale = true,
  },
  wg_np-vm-ol8 = {
    description = "OKE-managed Node Pool with OKE Oracle Linux 8 image", create = false,
    mode        = "node-pool", size = 1, size_max = 3, os = "Oracle Linux", os_version = "8", autoscale = true,
  },
  wg_np-vm-custom = {
    description = "OKE-managed Node Pool with custom image", create = true,
    mode        = "node-pool", image_type = "custom", size = 1, allow_autoscaler = true,
  },
  shielded_instances = {
    description = "Self-managed Shielded VM Instance", create = false,
    size = 1, mode = "instance", shape = "VM.Standard2.4",
    platform_config = {
      type                               = "INTEL_VM",
      is_measured_boot_enabled           = true,
      is_secure_boot_enabled             = true,
      is_trusted_platform_module_enabled = true,
    }
  }
  wg_ip-vm-custom = {
    description = "Self-managed Instance Pool with custom image", create = false,
    mode        = "instance-pool", image_type = "custom", size = 1, allow_autoscaler = true,
    node_labels = { "keya" : "valuea", "keyb" : "valueb" },
    secondary_vnics = {
      "vnic-display-name" = {},
    },
  },
  wg_cn-bm-rdma = {
    description = "Self-managed Cluster Network", create = false,
    mode        = "cluster-network", image_type = "custom", size = 1, shape = "BM.GPU.B4.8", placement_ads = [1],
  },
}

# Copyright (c) 2025 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

worker_compute_clusters = { # Use this variable to define a compute cluster you intend to use with multiple-nodepools.
  "shared" = {
    placement_ad = 1
  }
}

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

  compute-cluster-group-1 = {
    shape                    = "BM.HPC2.36",
    boot_volume_size         = 100,
    image_id                 = "ocid1.image.oc1..."
    image_type               = "custom"
    mode                     = "compute-cluster"
    compute_cluster          = "shared"
    instance_ids             = ["1", "2", "3"] # List of instance IDs in the compute cluster. Each instance ID corresponds to a separate node in the cluster.
    placement_ad             = "1"
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

  compute-cluster-group-2 = {
    shape                    = "BM.HPC2.36",
    boot_volume_size         = 100,
    image_id                 = "ocid1.image.oc1..."
    image_type               = "custom"
    mode                     = "compute-cluster"
    compute_cluster          = "shared"
    instance_ids             = ["a", "b", "c"] # List of instance IDs in the compute cluster. Each instance ID corresponds to a separate node in the cluster.
    placement_ad             = "1"
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

compute-cluster-group-3 = {
    shape                    = "BM.HPC2.36",
    boot_volume_size         = 100,
    image_id                 = "ocid1.image.oc1..."
    image_type               = "custom"
    mode                     = "compute-cluster"
    instance_ids             = ["001", "002", "003"] # List of instance IDs in the compute cluster. Each instance ID corresponds to a separate node in the cluster.
    placement_ad             = "1"
    cloud_init = [
      {
        content = <<-EOT
        #!/usr/bin/env bash
        echo "Pool-specific cloud_init using shell script"
        EOT
      },
    ],
  }
}

# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

worker_pools = {
  oke-instance = {
    agent_config = {
      are_all_plugins_disabled = false,
      is_management_disabled   = false,
      is_monitoring_disabled   = false,
      plugins_config = {
        "Bastion"                             = "DISABLED",
        "Block Volume Management"             = "DISABLED",
        "Compute HPC RDMA Authentication"     = "DISABLED",
        "Compute HPC RDMA Auto-Configuration" = "DISABLED",
        "Compute Instance Monitoring"         = "ENABLED",
        "Compute Instance Run Command"        = "ENABLED",
        "Compute RDMA GPU Monitoring"         = "DISABLED",
        "Custom Logs Monitoring"              = "ENABLED",
        "Management Agent"                    = "ENABLED",
        "Oracle Autonomous Linux"             = "DISABLED",
        "OS Management Service Agent"         = "DISABLED",
      }
    }
  },
}

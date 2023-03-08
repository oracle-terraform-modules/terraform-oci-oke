# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  drain_enabled = var.expected_node_count > 0 && var.worker_pools != null
  worker_pools_draining = (local.drain_enabled
    ? { for k, v in var.worker_pools : k => v if tobool(lookup(v, "drain", false)) } : {}
  )
}

resource "null_resource" "drain_workers" {
  count = local.drain_enabled ? 1 : 0
  triggers = {
    drain_workers = jsonencode(sort(keys(local.worker_pools_draining)))
  }

  connection {
    bastion_host        = var.bastion_host
    bastion_user        = var.bastion_user
    bastion_private_key = var.ssh_private_key
    host                = var.operator_host
    user                = var.operator_user
    private_key         = var.ssh_private_key
    timeout             = "40m"
    type                = "ssh"
  }

  provisioner "remote-exec" {
    inline = [
      "echo kubectl get nodes ...",             # TODO List nodes by label for draining pools
      "echo kubectl drain --ignore-daemonsets", # TODO Drain nodes for draining pools
    ]
  }
}

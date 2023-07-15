# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  drain_enabled = var.expected_drain_count > 0
  drain_pools = (local.drain_enabled
    ? tolist([for k, v in var.worker_pools : k if tobool(lookup(v, "drain", false))]) : []
  )

  drain_commands = formatlist(
    format(
      "kubectl drain %v %v %v %v",
      format("--timeout=%vs", var.worker_drain_timeout_seconds),
      format("--ignore-daemonsets=%v", var.worker_drain_ignore_daemonsets),
      format("--delete-emptydir-data=%v", var.worker_drain_delete_local_data),
      "-l oke.oraclecloud.com/pool.name=%v" # interpolation deferred to formatlist
    ),
    local.drain_pools
  )
}

resource "null_resource" "drain_workers" {
  count = local.drain_enabled ? 1 : 0
  triggers = {
    drain_pools    = jsonencode(sort(local.drain_pools))
    drain_commands = jsonencode(local.drain_commands)
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
    inline = local.drain_commands
  }
}

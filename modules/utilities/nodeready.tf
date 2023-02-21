# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  node_ready_script = "/home/${var.operator_user}/await_node_ready.sh"
  node_ready_template = templatefile("${path.module}/resources/await_node_readiness.tpl.sh",
    {
      await_node_readiness = var.await_node_readiness
      expected_node_count  = var.expected_node_count
    }
  )
}

resource "null_resource" "await_node_readiness" {
  count    = var.await_node_readiness != "none" && var.expected_node_count > 0 ? 1 : 0
  triggers = { expected_node_count = var.expected_node_count }

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

  provisioner "file" {
    content     = local.node_ready_template
    destination = local.node_ready_script
  }

  provisioner "remote-exec" {
    inline = ["bash ${local.node_ready_script}"]
  }
}

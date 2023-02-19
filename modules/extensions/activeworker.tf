# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  check_active_worker_template = templatefile("${path.module}/scripts/check_worker_active.template.sh", {
    await_node_readiness = var.await_node_readiness
    expected_node_count  = var.expected_node_count
    }
  )
}

resource "null_resource" "check_worker_active" {
  triggers = {
    expected_node_count = var.expected_node_count
  }

  connection {
    host        = var.operator_private_ip
    private_key = var.ssh_private_key
    timeout     = "40m"
    type        = "ssh"
    user        = var.operator_user

    bastion_host        = var.bastion_public_ip
    bastion_user        = var.bastion_user
    bastion_private_key = var.ssh_private_key
  }

  depends_on = [null_resource.write_kubeconfig_on_operator]

  provisioner "file" {
    content     = local.check_active_worker_template
    destination = "/home/${var.operator_user}/check_active_worker.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "bash \"/home/${var.operator_user}/check_active_worker.sh\"",
    ]
  }

  count = var.await_node_readiness != "none" && var.expected_node_count > 0 ? 1 : 0
}

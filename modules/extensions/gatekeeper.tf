# Copyright (c) 2021, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  gatekeeper_template = templatefile("${path.module}/scripts/install_gatekeeper.template.sh", {
    enable_gatekeeper  = var.enable_gatekeeper
    gatekeeper_version = var.gatekeeper_version
    }
  )
}

resource "null_resource" "enable_gatekeeper" {
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
    content     = local.gatekeeper_template
    destination = "/home/${var.operator_user}/enable_gatekeeper.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "if [ -f \"$HOME/enable_gatekeeper.sh\" ]; then bash \"$HOME/enable_gatekeeper.sh\"; rm -f \"$HOME/enable_gatekeeper.sh\";fi",
    ]
  }

  count = var.enable_gatekeeper ? 1 : 0
}

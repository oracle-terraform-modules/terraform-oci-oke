# Copyright 2017, 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "null_resource" "install_k8stools_on_operator" {
  connection {
    host        = var.operator_private_ip
    private_key = local.ssh_private_key
    timeout     = "40m"
    type        = "ssh"
    user        = var.operator_user

    bastion_host        = var.bastion_public_ip
    bastion_user        = var.bastion_user
    bastion_private_key = local.ssh_private_key
  }

  provisioner "file" {
    content     = local.install_kubectx_template
    destination = "/home/opc/install_kubectx.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "if [ -f \"$HOME/install_kubectx.sh\" ]; then bash \"$HOME/install_kubectx.sh\"; rm -f \"$HOME/install_kubectx.sh\";fi",
    ]
  }

  count = var.create_bastion_host == true && var.bastion_state == "RUNNING" && var.create_operator == true && var.operator_state == "RUNNING" ? 1 : 0
}

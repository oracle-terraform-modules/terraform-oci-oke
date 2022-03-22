# Copyright 2017, 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "null_resource" "install_kubectl_on_operator" {
  connection {
    host        = var.operator_private_ip
    private_key = local.ssh_private_key
    timeout     = "40m"
    type        = "ssh"
    user        = "opc"

    bastion_host        = var.bastion_public_ip
    bastion_user        = "opc"
    bastion_private_key = local.ssh_private_key
  }

  provisioner "file" {
    content     = local.install_kubectl_template
    destination = "/home/opc/install_kubectl.sh"
  }

  provisioner "file" {
    content     = local.install_helm_template
    destination = "/home/opc/install_helm.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x $HOME/install_kubectl.sh",
      "$HOME/install_kubectl.sh",
      "rm -f $HOME/install_kubectl.sh",
      "chmod +x $HOME/install_helm.sh",
      "$HOME/install_helm.sh",
      "rm -f $HOME/install_helm.sh"
    ]
  }

  count = var.create_bastion_host == true && var.bastion_state == "RUNNING" && var.create_operator == true && var.operator_state == "RUNNING" ? 1 : 0
}

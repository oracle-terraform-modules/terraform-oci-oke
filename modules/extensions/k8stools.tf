# Copyright 2017, 2021 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "null_resource" "install_kubectl_operator" {
  connection {
    host        = var.operator_private_ip
    private_key = file(var.ssh_private_key_path)
    timeout     = "40m"
    type        = "ssh"
    user        = "opc"

    bastion_host        = var.bastion_public_ip
    bastion_user        = "opc"
    bastion_private_key = file(var.ssh_private_key_path)
  }

  provisioner "file" {
    content     = local.install_kubectl_template
    destination = "~/install_kubectl.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x $HOME/install_kubectl.sh",
      "bash $HOME/install_kubectl.sh",
      "rm -f $HOME/install_kubectl.sh"
    ]
  }

  count = var.create_bastion_host == true && var.bastion_state == "RUNNING" && var.create_operator == true ? 1 : 0
}

# helm
resource "null_resource" "install_helm_operator" {
  connection {
    host        = var.operator_private_ip
    private_key = file(var.ssh_private_key_path)
    timeout     = "40m"
    type        = "ssh"
    user        = "opc"

    bastion_host        = var.bastion_public_ip
    bastion_user        = "opc"
    bastion_private_key = file(var.ssh_private_key_path)
  }

  depends_on = [null_resource.install_kubectl_operator, null_resource.write_kubeconfig_on_operator]

  provisioner "file" {
    content     = local.install_helm_template
    destination = "~/install_helm.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x $HOME/install_helm.sh",
      "bash $HOME/install_helm.sh",
      "rm -f $HOME/install_helm.sh"
    ]
  }

  count = var.create_bastion_host == true && var.bastion_state == "RUNNING" && var.create_operator == true ? 1 : 0
}

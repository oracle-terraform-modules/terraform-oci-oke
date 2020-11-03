# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# kubectl
data "template_file" "install_kubectl" {
  template = file("${path.module}/scripts/install_kubectl.template.sh")
}

resource "null_resource" "install_kubectl_operator" {
  connection {
    host        = var.oke_operator.operator_private_ip
    private_key = file(var.oke_ssh_keys.ssh_private_key_path)
    timeout     = "40m"
    type        = "ssh"
    user        = "opc"

    bastion_host        = var.oke_operator.bastion_public_ip
    bastion_user        = "opc"
    bastion_private_key = file(var.oke_ssh_keys.ssh_private_key_path)
  }

  provisioner "file" {
    content     = data.template_file.install_kubectl.rendered
    destination = "~/install_kubectl.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x $HOME/install_kubectl.sh",
      "bash $HOME/install_kubectl.sh",
      "rm -f $HOME/install_kubectl.sh"
    ]
  }

  count = var.oke_operator.bastion_enabled == true && var.oke_operator.operator_enabled == true ? 1 : 0
}

# wait for 1. operator being ready 2. kubectl is installed (the script will create the .kube directory)
resource null_resource "wait_for_operator" {
  connection {
    host        = var.oke_operator.operator_private_ip
    private_key = file(var.oke_ssh_keys.ssh_private_key_path)
    timeout     = "40m"
    type        = "ssh"
    user        = "opc"

    bastion_host        = var.oke_operator.bastion_public_ip
    bastion_user        = "opc"
    bastion_private_key = file(var.oke_ssh_keys.ssh_private_key_path)
  }

  depends_on = [null_resource.install_kubectl_operator]

  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /home/opc/operator.finish ]; do sleep 10; done",
    ]
  }

  count = var.oke_operator.bastion_enabled == true && var.oke_operator.operator_enabled == true ? 1 : 0
}

# helm
data "template_file" "install_helm" {
  template = file("${path.module}/scripts/install_helm.template.sh")

  count = var.oke_operator.operator_enabled == true ? 1 : 0
}

resource null_resource "install_helm_operator" {
  connection {
    host        = var.oke_operator.operator_private_ip
    private_key = file(var.oke_ssh_keys.ssh_private_key_path)
    timeout     = "40m"
    type        = "ssh"
    user        = "opc"

    bastion_host        = var.oke_operator.bastion_public_ip
    bastion_user        = "opc"
    bastion_private_key = file(var.oke_ssh_keys.ssh_private_key_path)
  }

  depends_on = [null_resource.install_kubectl_operator, null_resource.write_kubeconfig_on_operator]

  provisioner "file" {
    content     = data.template_file.install_helm[0].rendered
    destination = "~/install_helm.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x $HOME/install_helm.sh",
      "bash $HOME/install_helm.sh",
      "rm -f $HOME/install_helm.sh"
    ]
  }

  count = var.oke_operator.bastion_enabled == true && var.oke_operator.operator_enabled == true ? 1 : 0
}

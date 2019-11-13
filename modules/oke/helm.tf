# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

data "template_file" "install_helm" {
  template = file("${path.module}/scripts/install_helm.template.sh")

  vars = {
    add_incubator_repo = var.helm.add_incubator_repo
    add_jetstack_repo  = var.helm.add_jetstack_repo
    helm_version       = var.helm.helm_version
  }

  count = var.oke_admin.create_bastion == true && var.helm.install_helm == true ? 1 : 0
}

resource null_resource "install_helm_bastion" {
  connection {
    host        = var.oke_admin.admin_private_ip
    private_key = file(var.oke_ssh_keys.ssh_private_key_path)
    timeout     = "40m"
    type        = "ssh"
    user        = "opc"

    bastion_host        = var.oke_admin.bastion_public_ip
    bastion_user        = "opc"
    bastion_private_key = file(var.oke_ssh_keys.ssh_private_key_path)
  }

  depends_on = ["null_resource.install_kubectl_bastion", "null_resource.write_kubeconfig_on_admin"]

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

  count = var.oke_admin.create_bastion == true && var.helm.install_helm == true ? 1 : 0
}

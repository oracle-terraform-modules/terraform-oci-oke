## Copyright 2017, 2021 Oracle Corporation and/or affiliates.
## Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "null_resource" "install_calico" {
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

  depends_on = [null_resource.install_kubectl_operator, null_resource.write_kubeconfig_on_operator]

  provisioner "file" {
    content     = local.install_calico_template
    destination = "~/install_sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x $HOME/install_sh",
      "$HOME/install_sh",
      # "rm -f $HOME/install_sh"
    ]
  }

  count = local.post_provisioning_ops == true && var.install_calico == true ? 1 : 0
}

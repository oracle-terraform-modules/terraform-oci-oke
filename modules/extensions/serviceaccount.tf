# Copyright 2017, 2019 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "null_resource" "create_service_account" {
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

  depends_on = [null_resource.install_kubectl_on_operator, null_resource.write_kubeconfig_on_operator]

  provisioner "file" {
    content     = local.create_service_account_template
    destination = "/home/opc/create_service_account.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x $HOME/create_service_account.sh",
      "$HOME/create_service_account.sh",
      "rm -f $HOME/create_service_account.sh"
    ]
  }

  count = local.post_provisioning_ops == true && var.create_service_account == true ? 1 : 0
}

# # Copyright 2017, 2021 Oracle Corporation and/or affiliates.  All rights reserved.
# # Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "null_resource" "secret" {
  triggers = {
    always_run = "${timestamp()}"
  }
  connection {
    host        = var.operator_private_ip
    private_key = (var.ssh_private_key != "") ? var.ssh_private_key : (var.ssh_private_key_path != "none") ? file(var.ssh_private_key_path) : null
    timeout     = "40m"
    type        = "ssh"
    user        = "opc"

    bastion_host        = var.bastion_public_ip
    bastion_user        = "opc"
    bastion_private_key = (var.ssh_private_key != "") ? var.ssh_private_key : (var.ssh_private_key_path != "none") ? file(var.ssh_private_key_path) : null
  }

  depends_on = [null_resource.write_kubeconfig_on_operator]

  provisioner "file" {
    content     = local.secret_template
    destination = "~/secret.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x $HOME/secret.sh",
      "$HOME/secret.sh",
      "sleep 10",
      "rm -f $HOME/secret.sh"
    ]
  }

  count = local.post_provisioning_ops == true && var.secret_id != "none" ? 1 : 0
}

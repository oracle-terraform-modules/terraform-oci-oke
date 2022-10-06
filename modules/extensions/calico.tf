## Copyright 2017, 2021 Oracle Corporation and/or affiliates.
## Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "null_resource" "install_calico" {
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

  depends_on = [null_resource.install_k8stools_on_operator, null_resource.write_kubeconfig_on_operator]

  provisioner "file" {
    content     = local.install_calico_template
    destination = "/home/opc/install_calico.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "if [ -f \"$HOME/install_calico.sh\" ]; then bash \"$HOME/install_calico.sh\"; rm -f \"$HOME/install_calico.sh\";fi",
    ]
  }

  count = local.post_provisioning_ops == true && var.install_calico == true ? 1 : 0
}

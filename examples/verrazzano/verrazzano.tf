## Copyright 2017, 2021 Oracle Corporation and/or affiliates.
## Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "null_resource" "install_verrazzano" {
  connection {
    host        = module.oke.operator_private_ip
    private_key = file(var.ssh_private_key_path)
    timeout     = "40m"
    type        = "ssh"
    user        = "opc"

    bastion_host        = module.oke.bastion_public_ip
    bastion_user        = "opc"
    bastion_private_key = file(var.ssh_private_key_path)
  }

  depends_on = [module.oke]

  provisioner "file" {
    content     = local.install_verrazzano_operator_template
    destination = "/home/opc/install_verrazzano_operator"
  }

  provisioner "file" {
    content     = local.install_verrazzano_template
    destination = "/home/opc/install_verrazzano"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x $HOME/install_verrazzano_operator",
      "chmod +x $HOME/install_verrazzano",
      "$HOME/install_verrazzano_operator",
      "$HOME/install_verrazzano"
    ]
  }
}

# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl
data "template_file" "create_ocir_script" {
  template = file("${path.module}/scripts/create_ocir_secret.template.sh")

  vars = {
    authtoken       = var.oke_ocir.auth_token
    email_address   = var.oke_ocir.email_address
    region_registry = var.oke_ocir.ocir_urls[var.oke_general.region]
    tenancy_name    = var.oke_ocir.tenancy_name
    username        = var.oke_ocir.username
  }

  count = var.oke_ocir.create_auth_token == true ? 1 : 0
}

resource null_resource "create_ocir_secret" {
  triggers = {
    ocirtoken = var.oke_ocir.ocirtoken_id
  }

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

  depends_on = [null_resource.write_kubeconfig_on_admin]
  
  provisioner "file" {
    content     = data.template_file.create_ocir_script[0].rendered
    destination = "~/create_ocir_secret.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x $HOME/create_ocir_secret.sh",
      "$HOME/create_ocir_secret.sh",
    ]
  }

  count = var.oke_admin.bastion_enabled == true && var.oke_admin.admin_enabled == true && var.oke_ocir.create_auth_token == true ? 1 : 0
}

resource null_resource "delete_ocir_script" {
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

  depends_on = [null_resource.create_ocir_secret]

  provisioner "remote-exec" {
    inline = [
      "rm -f $HOME/create_ocir_secret.sh",
    ]
  }

  count = var.oke_admin.bastion_enabled == true && var.oke_admin.admin_enabled == true && var.oke_ocir.create_auth_token == true ? 1 : 0
}

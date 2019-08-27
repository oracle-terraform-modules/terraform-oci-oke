# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl
data "template_file" "create_ocir_script" {
  template = file("${path.module}/scripts/create_ocir_secret.template.sh")

  vars = {
    authtoken       = var.ocir.auth_token
    email_address   = var.ocir.email_address
    region_registry = var.ocir.ocir_urls[var.oke_general.region]
    tenancy_name    = var.ocir.tenancy_name
    username        = var.ocir.username
    tiller_enabled  = var.oke_cluster.cluster_options_add_ons_is_tiller_enabled
  }

  count = var.ocir.create_auth_token == true   ? 1 : 0
}

resource null_resource "create_ocir_secret" {
  triggers = {
    ocirtoken = var.ocir.ocirtoken_id
  }

  connection {
    host        = var.oke_bastion.bastion_public_ip
    private_key = file(var.oke_ssh_keys.ssh_private_key_path)
    timeout     = "40m"
    type        = "ssh"
    user        = var.oke_bastion.image_operating_system == "Canonical Ubuntu"   ? "ubuntu" : "opc"
  }

  depends_on = ["null_resource.write_kubeconfig_bastion"]
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

  count = var.oke_bastion.create_bastion == true  && var.ocir.create_auth_token == true ? 1 : 0
}

resource null_resource "delete_ocir_script" {
  depends_on = ["null_resource.create_ocir_secret"]

  connection {
    host        = var.oke_bastion.bastion_public_ip
    private_key = file(var.oke_ssh_keys.ssh_private_key_path)
    timeout     = "40m"
    type        = "ssh"
    user        = var.oke_bastion.image_operating_system == "Canonical Ubuntu"   ? "ubuntu" : "opc"
  }

  provisioner "remote-exec" {
    inline = [
      "rm -f $HOME/create_ocir_secret.sh",
    ]
  }

  count = var.oke_bastion.create_bastion == true && var.ocir.create_auth_token == true ? 1 : 0
}

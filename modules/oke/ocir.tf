# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

data "template_file" "create_ocir_script" {
  template = "${file("${path.module}/scripts/create_ocir_secret.template.sh")}"

  vars = {
    authtoken       = "${var.auth_token}"
    email_address   = "${var.email_address}"
    region_registry = "${var.ocir_urls["${var.region}"]}"
    tenancy_name    = "${var.tenancy_name}"
    username        = "${var.username}"
  }

  count = "${var.create_auth_token == true   ? 1 : 0}"
}

resource null_resource "write_ocir_script" {
  triggers = {
    ocirtoken = "${var.ocirtoken_id}"
  }

  connection {
    host        = "${var.bastion_public_ip}"
    private_key = "${file(var.ssh_private_key_path)}"
    timeout     = "40m"
    type        = "ssh"
    user        = "${var.preferred_bastion_image == "ubuntu"   ? "ubuntu" : "opc"}"
  }

  provisioner "file" {
    content     = "${data.template_file.create_ocir_script.rendered}"
    destination = "~/create_ocir_secret.sh"
  }

  count = "${(var.availability_domains["bastion"] == 1 && var.create_auth_token == true ) ? 1 : 0}"
}

resource null_resource "create_ocir_secret" {
  depends_on = ["null_resource.write_ocir_script", "null_resource.write_kubeconfig_bastion"]

  triggers = {
    ocirtoken = "${var.ocirtoken_id}"
  }

  connection {
    host        = "${var.bastion_public_ip}"
    private_key = "${file(var.ssh_private_key_path)}"
    timeout     = "40m"
    type        = "ssh"
    user        = "${var.preferred_bastion_image == "ubuntu"   ? "ubuntu" : "opc"}"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x ~/create_ocir_secret.sh",
      "~/create_ocir_secret.sh",
    ]
  }

  count = "${(var.availability_domains["bastion"] == 1 && var.create_auth_token == true ) ? 1 : 0}"
}

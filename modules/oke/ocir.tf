# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

data "template_file" "create_ocir_script" {
  template = "${file("${path.module}/scripts/create_ocir_secret.template.sh")}"

  vars = {
    region_registry = "${var.ocir_urls["${var.region}"]}"
    tenancy_name    = "${var.tenancy_name}"
    username        = "${var.username}"
    email_address   = "${var.email_address}"
    authtoken       = "${var.auth_token}"
  }

  count = "${var.create_auth_token == "true"   ? 1 : 0}"
}

resource null_resource "write_ocir_script_ad1" {
  triggers = {
    ocirtoken = "${var.ocirtoken_id}"
  }

  connection {
    type        = "ssh"
    host        = "${var.bastion_public_ips["ad1"]}"
    user        = "${var.preferred_bastion_image == "ubuntu"   ? "ubuntu" : "opc"}"
    private_key = "${file(var.ssh_private_key_path)}"
    timeout     = "40m"
  }

  provisioner "file" {
    content     = "${data.template_file.create_ocir_script.rendered}"
    destination = "~/create_ocir_secret.sh"
  }

  count = "${(var.availability_domains["bastion_ad1"] == "true" && var.create_auth_token == "true" ) ? 1 : 0}"
}

resource null_resource "create_ocir_secret_ad1" {
  depends_on = ["null_resource.write_ocir_script_ad1", "null_resource.write_kubeconfig_bastion1"]

  triggers = {
    ocirtoken = "${var.ocirtoken_id}"
  }

  connection {
    type        = "ssh"
    host        = "${var.bastion_public_ips["ad1"]}"
    user        = "${var.preferred_bastion_image == "ubuntu"   ? "ubuntu" : "opc"}"
    private_key = "${file(var.ssh_private_key_path)}"
    timeout     = "40m"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x ~/create_ocir_secret.sh",
      "~/create_ocir_secret.sh",
    ]
  }

  count = "${(var.availability_domains["bastion_ad1"] == "true" && var.create_auth_token == "true" ) ? 1 : 0}"
}

resource null_resource "write_ocir_script_ad2" {
  triggers = {
    ocirtoken = "${var.ocirtoken_id}"
  }

  connection {
    type        = "ssh"
    host        = "${var.bastion_public_ips["ad2"]}"
    user        = "${var.preferred_bastion_image == "ubuntu"   ? "ubuntu" : "opc"}"
    private_key = "${file(var.ssh_private_key_path)}"
    timeout     = "40m"
  }

  provisioner "file" {
    content     = "${data.template_file.create_ocir_script.rendered}"
    destination = "~/create_ocir_secret.sh"
  }

  count = "${(var.availability_domains["bastion_ad2"] == "true" && var.create_auth_token == "true" ) ? 1 : 0}"
}

resource null_resource "create_ocir_secret_ad2" {
  depends_on = ["null_resource.write_ocir_script_ad2", "null_resource.write_kubeconfig_bastion2"]

  triggers = {
    ocirtoken = "${var.ocirtoken_id}"
  }

  connection {
    type        = "ssh"
    host        = "${var.bastion_public_ips["ad2"]}"
    user        = "${var.preferred_bastion_image == "ubuntu"   ? "ubuntu" : "opc"}"
    private_key = "${file(var.ssh_private_key_path)}"
    timeout     = "40m"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x ~/create_ocir_secret.sh",
      "~/create_ocir_secret.sh",
    ]
  }

  count = "${(var.availability_domains["bastion_ad2"] == "true" && var.create_auth_token == "true" ) ? 1 : 0}"
}

resource null_resource "write_ocir_script_ad3" {
  triggers = {
    ocirtoken = "${var.ocirtoken_id}"
  }

  connection {
    type        = "ssh"
    host        = "${var.bastion_public_ips["ad3"]}"
    user        = "${var.preferred_bastion_image == "ubuntu"   ? "ubuntu" : "opc"}"
    private_key = "${file(var.ssh_private_key_path)}"
    timeout     = "40m"
  }

  provisioner "file" {
    content     = "${data.template_file.create_ocir_script.rendered}"
    destination = "~/create_ocir_secret.sh"
  }

  count = "${(var.availability_domains["bastion_ad3"] == "true" && var.create_auth_token == "true" ) ? 1 : 0}"
}

resource null_resource "create_ocir_secret_ad3" {
  depends_on = ["null_resource.write_ocir_script_ad3", "null_resource.write_kubeconfig_bastion3"]

  triggers = {
    ocirtoken = "${var.ocirtoken_id}"
  }

  connection {
    type        = "ssh"
    host        = "${var.bastion_public_ips["ad3"]}"
    user        = "${var.preferred_bastion_image == "ubuntu"   ? "ubuntu" : "opc"}"
    private_key = "${file(var.ssh_private_key_path)}"
    timeout     = "40m"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x ~/create_ocir_secret.sh",
      "~/create_ocir_secret.sh",
    ]
  }

  count = "${(var.availability_domains["bastion_ad3"] == "true" && var.create_auth_token == "true" ) ? 1 : 0}"
}

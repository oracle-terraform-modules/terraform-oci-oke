# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

data "template_file" "install_helm" {
  template = "${file("${path.module}/scripts/install_helm.template.sh")}"

  vars = {
    helm_version = "${var.helm_version}"
  }
}

resource null_resource "write_install_helm_bastion" {
  connection {
    host        = "${var.bastion_public_ip}"
    private_key = "${file(var.ssh_private_key_path)}"
    timeout     = "40m"
    type        = "ssh"
    user        = "${var.preferred_bastion_image == "ubuntu"   ? "ubuntu" : "opc"}"
  }

  provisioner "file" {
    content     = "${data.template_file.install_helm.rendered}"
    destination = "~/install_helm.sh"
  }

  count = "${(var.create_bastion == true && var.install_helm == true)   ? 1 : 0}"
}

resource null_resource "install_helm_bastion" {
  connection {
    host        = "${var.bastion_public_ip}"
    private_key = "${file(var.ssh_private_key_path)}"
    timeout     = "40m"
    type        = "ssh"
    user        = "${var.preferred_bastion_image == "ubuntu"   ? "ubuntu" : "opc"}"
  }

  depends_on = ["null_resource.write_install_helm_bastion", "null_resource.write_kubeconfig_bastion", "null_resource.install_kubectl_bastion"]

  provisioner "remote-exec" {
    inline = [
      "chmod +x ~/install_helm.sh",
      "~/install_helm.sh",
      "echo \"source <(helm completion bash)\" >> ~/.bashrc",
    ]
  }

  count = "${(var.create_bastion == true && var.install_helm == true)   ? 1 : 0}"
}

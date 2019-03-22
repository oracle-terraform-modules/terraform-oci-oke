# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

data "template_file" "install_helm" {
  template = "${file("${path.module}/scripts/install_helm.template.sh")}"

  vars = {
    helm_version = "${var.helm_version}"
  }
}

resource null_resource "write_install_helm_bastion1" {
  connection {
    type        = "ssh"
    host        = "${var.bastion_public_ips["ad1"]}"
    user        = "${var.preferred_bastion_image == "ubuntu"   ? "ubuntu" : "opc"}"
    private_key = "${file(var.ssh_private_key_path)}"
    timeout     = "40m"
  }

  provisioner "file" {
    content     = "${data.template_file.install_helm.rendered}"
    destination = "~/install_helm.sh"
  }

  count = "${(var.availability_domains["bastion_ad1"] == "true" && var.install_helm == "true")   ? 1 : 0}"
}

resource null_resource "install_helm_bastion1" {
  depends_on = ["null_resource.write_install_helm_bastion1", "null_resource.write_kubeconfig_bastion1", "null_resource.install_kubectl_bastion1"]

  connection {
    type        = "ssh"
    host        = "${var.bastion_public_ips["ad1"]}"
    user        = "${var.preferred_bastion_image == "ubuntu"   ? "ubuntu" : "opc"}"
    private_key = "${file(var.ssh_private_key_path)}"
    timeout     = "40m"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x ~/install_helm.sh",
      "~/install_helm.sh",
      "echo \"source <(helm completion bash)\" >> ~/.bashrc",
    ]
  }

  count = "${(var.availability_domains["bastion_ad1"] == "true" && var.install_helm == "true")   ? 1 : 0}"
}

resource null_resource "write_install_helm_bastion2" {
  connection {
    type        = "ssh"
    host        = "${var.bastion_public_ips["ad2"]}"
    user        = "${var.preferred_bastion_image == "ubuntu"   ? "ubuntu" : "opc"}"
    private_key = "${file(var.ssh_private_key_path)}"
    timeout     = "40m"
  }

  provisioner "file" {
    content     = "${data.template_file.install_helm.rendered}"
    destination = "~/install_helm.sh"
  }

  count = "${(var.availability_domains["bastion_ad2"] == "true" && var.install_helm == "true")   ? 1 : 0}"
}

resource null_resource "install_helm_bastion2" {
  depends_on = [ "null_resource.write_install_helm_bastion2", "null_resource.write_kubeconfig_bastion2", "null_resource.install_kubectl_bastion2"]

  connection {
    type        = "ssh"
    host        = "${var.bastion_public_ips["ad2"]}"
    user        = "${var.preferred_bastion_image == "ubuntu"   ? "ubuntu" : "opc"}"
    private_key = "${file(var.ssh_private_key_path)}"
    timeout     = "40m"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x ~/install_helm.sh",
      "~/install_helm.sh",
      "echo \"source <(helm completion bash)\" >> ~/.bashrc",
    ]
  }

  count = "${(var.availability_domains["bastion_ad2"] == "true" && var.install_helm == "true")   ? 1 : 0}"
}

resource null_resource "write_install_helm_bastion3" {
  connection {
    type        = "ssh"
    host        = "${var.bastion_public_ips["ad3"]}"
    user        = "${var.preferred_bastion_image == "ubuntu"   ? "ubuntu" : "opc"}"
    private_key = "${file(var.ssh_private_key_path)}"
    timeout     = "40m"
  }

  provisioner "file" {
    content     = "${data.template_file.install_helm.rendered}"
    destination = "~/install_helm.sh"
  }

  count = "${(var.availability_domains["bastion_ad3"] == "true" && var.install_helm == "true")   ? 1 : 0}"
}

resource null_resource "install_helm_bastion3" {
  depends_on = ["null_resource.write_install_helm_bastion3", "null_resource.write_kubeconfig_bastion3", "null_resource.install_kubectl_bastion3"]

  connection {
    type        = "ssh"
    host        = "${var.bastion_public_ips["ad3"]}"
    user        = "${var.preferred_bastion_image == "ubuntu"   ? "ubuntu" : "opc"}"
    private_key = "${file(var.ssh_private_key_path)}"
    timeout     = "40m"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x ~/install_helm.sh",
      "~/install_helm.sh",
      "echo \"source <(helm completion bash)\" >> ~/.bashrc",
    ]
  }

  count = "${(var.availability_domains["bastion_ad3"] == "true" && var.install_helm == "true")   ? 1 : 0}"
}

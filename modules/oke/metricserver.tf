# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

data "template_file" "metricserver_enabled" {
  template = file("${path.module}/scripts/install_metricserver.template.sh")

  vars = {
    vpa_enabled = var.vpa.enabled
    vpa_version = var.vpa.version
  }

  count = var.metricserver_enabled == true ? 1 : 0
}

resource null_resource "metricserver_enabled" {
  connection {
    host        = var.oke_operator.operator_private_ip
    private_key = file(var.oke_ssh_keys.ssh_private_key_path)
    timeout     = "40m"
    type        = "ssh"
    user        = "opc"

    bastion_host        = var.oke_operator.bastion_public_ip
    bastion_user        = "opc"
    bastion_private_key = file(var.oke_ssh_keys.ssh_private_key_path)
  }

  depends_on = [null_resource.install_kubectl_operator, null_resource.write_kubeconfig_on_operator]

  provisioner "file" {
    content     = data.template_file.metricserver_enabled[0].rendered
    destination = "~/metricserver_enabled.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x $HOME/metricserver_enabled.sh",
      "$HOME/metricserver_enabled.sh",
      "rm -f $HOME/metricserver_enabled.sh"
    ]
  }

  count = var.oke_operator.bastion_enabled == true && var.oke_operator.operator_enabled == true && var.metricserver_enabled == true ? 1 : 0
}

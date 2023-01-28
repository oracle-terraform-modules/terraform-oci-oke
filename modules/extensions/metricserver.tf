# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  metric_server_template = templatefile("${path.module}/scripts/install_metricserver.template.sh", {
    enable_vpa  = var.enable_vpa
    vpa_version = var.vpa_version
    }
  )
}

resource "null_resource" "enable_metric_server" {
  connection {
    host        = var.operator_private_ip
    private_key = var.ssh_private_key
    timeout     = "40m"
    type        = "ssh"
    user        = var.operator_user

    bastion_host        = var.bastion_public_ip
    bastion_user        = var.bastion_user
    bastion_private_key = var.ssh_private_key
  }

  depends_on = [null_resource.write_kubeconfig_on_operator]

  provisioner "file" {
    content     = local.metric_server_template
    destination = "/home/${var.operator_user}/enable_metric_server.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "if [ -f \"$HOME/enable_metric_server.sh\" ]; then bash \"$HOME/enable_metric_server.sh\"; rm -f \"$HOME/enable_metric_server.sh\";fi",
    ]
  }

  count = var.enable_metric_server ? 1 : 0
}

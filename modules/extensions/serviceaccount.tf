# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  create_service_account_template = templatefile("${path.module}/scripts/create_service_account.template.sh",
    {
      service_account_name                 = var.service_account_name
      service_account_namespace            = var.service_account_namespace
      service_account_cluster_role_binding = local.service_account_cluster_role_binding_name
    }
  )

  service_account_cluster_role_binding_name = var.service_account_cluster_role_binding == "" ? "${var.service_account_name}-crb" : var.service_account_cluster_role_binding
}

resource "null_resource" "create_service_account" {
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
    content     = local.create_service_account_template
    destination = "/home/${var.operator_user}/create_service_account.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "if [ -f \"$HOME/create_service_account.sh\" ]; then bash \"$HOME/create_service_account.sh\"; rm -f \"$HOME/create_service_account.sh\";fi",
    ]
  }

  count = var.create_service_account ? 1 : 0
}

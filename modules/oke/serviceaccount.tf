# Copyright 2017, 2019 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# data "template_file" "create_service_account" {
#   template = file("${path.module}/scripts/create_service_account.template.sh")

#   vars = {
#     service_account_name                 = var.service_account_name
#     service_account_namespace            = var.service_account_namespace
#     service_account_cluster_role_binding = local.service_account_cluster_role_binding_name
#   }

#   count = var.create_service_account == true ? 1 : 0
# }

locals {
  create_service_account_template = templatefile("${path.module}/scripts/create_service_account.template.sh",
    {
      service_account_name                 = var.service_account_name
      service_account_namespace            = var.service_account_namespace
      service_account_cluster_role_binding = local.service_account_cluster_role_binding_name
    }
  )
}

resource "null_resource" "create_service_account" {
  connection {
    host        = var.operator_private_ip
    private_key = file(var.ssh_private_key_path)
    timeout     = "40m"
    type        = "ssh"
    user        = "opc"

    bastion_host        = var.bastion_public_ip
    bastion_user        = "opc"
    bastion_private_key = file(var.ssh_private_key_path)
  }

  depends_on = [null_resource.install_kubectl_operator, null_resource.write_kubeconfig_on_operator]

  provisioner "file" {
    # content     = data.template_file.create_service_account[0].rendered
    content = local.create_service_account_template
    destination = "~/create_service_account.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x $HOME/create_service_account.sh",
      "$HOME/create_service_account.sh",
      "rm -f $HOME/create_service_account.sh"
    ]
  }

  count = local.post_provisioning_ops == true && var.create_service_account == true ? 1 : 0
}

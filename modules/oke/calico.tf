## Copyright 2017, 2021 Oracle Corporation and/or affiliates.  All rights reserved.
## Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# data "template_file" "enable_calico" {
#   template = file("${path.module}/scripts/install_calico.template.sh")

# vars = {
#     calico_version     = var.calico_version
#     number_of_nodes    = local.total_nodes
#     pod_cidr           = var.cluster_options_kubernetes_network_config_pods_cidr
#     number_of_replicas = min(20, max((local.total_nodes) / 200, 3))
#   }  

#   count = var.install_calico == true ? 1 : 0
# }

locals {
  install_calico_template = templatefile("${path.module}/scripts/install_calico.template.sh",
    {
      calico_version     = var.calico_version
      number_of_nodes    = local.total_nodes
      pod_cidr           = var.cluster_options_kubernetes_network_config_pods_cidr
      number_of_replicas = min(20, max((local.total_nodes) / 200, 3))
    }
  )
}

resource "null_resource" "install_calico" {
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
    # content     = data.template_file.enable_calico[0].rendered
    content     = local.install_calico_template
    destination = "~/install_sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x $HOME/install_sh",
      "$HOME/install_sh",
      # "rm -f $HOME/install_sh"
    ]
  }

  count = local.post_provisioning_ops == true && var.install_calico == true ? 1 : 0
}

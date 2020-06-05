## Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
## Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

data "template_file" "calico_enabled" {
  template = file("${path.module}/scripts/install_calico.template.sh")

  vars = {
    calico_version     = var.calico.calico_version
    number_of_nodes    = local.total_nodes
    pod_cidr           = var.oke_cluster.cluster_options_kubernetes_network_config_pods_cidr
    number_of_replicas = min(20, max((local.total_nodes) / 200, 3))
  }

  count = var.calico.calico_enabled == true ? 1 : 0
}

resource null_resource "calico_enabled" {
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
    content     = data.template_file.calico_enabled[0].rendered
    destination = "~/calico_enabled.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x $HOME/calico_enabled.sh",
      "$HOME/calico_enabled.sh",
      "rm -f $HOME/calico_enabled.sh"
    ]
  }

  count = var.oke_operator.bastion_enabled == true && var.oke_operator.operator_enabled == true && var.calico.calico_enabled == true ? 1 : 0
}

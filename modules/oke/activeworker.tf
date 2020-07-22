# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

data "template_file" "check_active_worker" {
  template = file("${path.module}/scripts/check_worker_active.template.sh")

  vars = {
    check_node_active = var.check_node_active
    total_nodes       = local.total_nodes
  }
  count = var.oke_operator.operator_enabled == true && var.check_node_active != "none" ? 1 : 0
}

resource null_resource "check_worker_active" {  
  triggers = {
    node_pools = length(data.oci_containerengine_node_pools.all_node_pools.node_pools)
  }

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

  depends_on = [null_resource.write_kubeconfig_on_operator]

  provisioner "file" {
    content     = data.template_file.check_active_worker[0].rendered
    destination = "~/check_active_worker.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x $HOME/check_active_worker.sh",
      "$HOME/check_active_worker.sh"
      //"rm -f $HOME/check_active_worker.sh"
    ]
  }

  count = var.oke_operator.operator_enabled == true && var.check_node_active != "none" ? 1 : 0
}
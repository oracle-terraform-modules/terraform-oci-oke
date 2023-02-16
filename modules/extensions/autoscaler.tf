# Copyright (c) 2022 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# taint the nodes in the autoscaler pool to restrict deployment of pods to nodes with the autoscaler toleration
resource "null_resource" "taint_nodes" {
  connection {
    host        = var.operator_private_ip
    private_key = local.ssh_private_key
    timeout     = "40m"
    type        = "ssh"
    user        = "opc"

    bastion_host        = var.bastion_public_ip
    bastion_user        = "opc"
    bastion_private_key = local.ssh_private_key
  }

  provisioner "file" {
    content     = local.create_autoscaler_pool_taint_list_template
    destination = "/home/opc/create_autoscaler_pool_taint_list.py"
  }

  provisioner "file" {
    content     = local.taint_autoscaler_pool_template
    destination = "/home/opc/taint_autoscaler_pools.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "rm -f \"$HOME/taint_autoscaler_pool_list.txt\"",
      "if [ -f \"$HOME/create_autoscaler_pool_taint_list.py\" ]; then python3 \"$HOME/create_autoscaler_pool_taint_list.py\"; rm -f \"$HOME/create_autoscaler_pool_taint_list.py\";fi",
      "if [ -f \"$HOME/taint_autoscaler_pools.sh\" ]; then bash \"$HOME/taint_autoscaler_pools.sh\"; rm -f \"$HOME/taint_autoscaler_pools.sh\";fi",
      "if [ -f \"$HOME/taint_autoscaler_pool_list.txt\" ]; then cat \"$HOME/taint_autoscaler_pool_list.txt\" >> \"$HOME/taint_autoscaler_pool_list.txt\"; rm -f \"$HOME/taint_autoscaler_pool_list.txt\";fi",
    ]
  }

  depends_on = [null_resource.install_k8stools_on_operator, null_resource.write_kubeconfig_on_operator]  

  triggers = {
    autoscaler_pools = length(var.autoscaler_pools)
  }

  count = local.post_provisioning_ops == true && var.enable_cluster_autoscaler == true ? 1 : 0
}


resource "null_resource" "deploy_cluster_autoscaler" {
  connection {
    host        = var.operator_private_ip
    private_key = local.ssh_private_key
    timeout     = "40m"
    type        = "ssh"
    user        = "opc"

    bastion_host        = var.bastion_public_ip
    bastion_user        = "opc"
    bastion_private_key = local.ssh_private_key
  }

  provisioner "file" {
    content     = local.cluster_autoscaler_yaml_template
    destination = "/home/opc/cluster-autoscaler.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "if [ -f \"$HOME/cluster-autoscaler.yaml\" ]; then kubectl apply -f \"$HOME/cluster-autoscaler.yaml\";fi",
    ]
  }

  count = local.post_provisioning_ops == true && var.enable_cluster_autoscaler == true ? 1 : 0

  triggers = {bla="blabla"}
}
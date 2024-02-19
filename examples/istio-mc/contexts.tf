# Copyright (c) 2024 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "null_resource" "tools" {
  depends_on = [module.c1]

  connection {
    host        = local.operator_ip
    private_key = file(var.ssh_private_key_path)
    timeout     = "40m"
    type        = "ssh"
    user        = "opc"

    bastion_host        = local.bastion_ip
    bastion_user        = "opc"
    bastion_private_key = file(var.ssh_private_key_path)
  }

  provisioner "file" {
    content     = local.token_helper_template
    destination = "/home/opc/token_helper.sh"
  }

  provisioner "file" {
    content     = local.istioctl_template
    destination = "/home/opc/install_istioctl.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir /home/opc/bin; mv token_helper.sh /home/opc/bin; chmod +x /home/opc/bin/token_helper.sh",
      "if [ -f \"$HOME/install_istioctl.sh\" ]; then bash \"$HOME/install_istioctl.sh\";fi",
    ]
  }
}


resource "null_resource" "set_contexts" {
  depends_on = [module.c1, module.c2]
  for_each   = local.all_cluster_ids
  connection {
    host        = local.operator_ip
    private_key = file(var.ssh_private_key_path)
    timeout     = "40m"
    type        = "ssh"
    user        = "opc"

    bastion_host        = local.bastion_ip
    bastion_user        = "opc"
    bastion_private_key = file(var.ssh_private_key_path)
  }

  provisioner "file" {
    content     = lookup(local.kubeconfig_templates, each.key)
    destination = "/home/opc/generate_kubeconfig_${each.key}.sh"
  }

  provisioner "file" {
    content     = lookup(local.set_credentials_templates, each.key)
    destination = "/home/opc/kubeconfig_set_credentials_${each.key}.sh"
  }

  provisioner "file" {
    content     = lookup(local.set_alias_templates, each.key)
    destination = "/home/opc/set_alias_${each.key}.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "if [ -f \"$HOME/generate_kubeconfig_${each.key}.sh\" ]; then bash \"$HOME/generate_kubeconfig_${each.key}.sh\";fi",
      "if [ -f \"$HOME/kubeconfig_set_credentials_${each.key}.sh\" ]; then bash \"$HOME/kubeconfig_set_credentials_${each.key}.sh\";fi",
      "if [ -f \"$HOME/set_alias_${each.key}.sh\" ]; then bash \"$HOME/set_alias_${each.key}.sh\";fi",
    ]
  }

  triggers = {
    clusters = length(var.clusters)
  }

  lifecycle {
    create_before_destroy = true
  }

}

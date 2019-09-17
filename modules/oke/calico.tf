## Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
## Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

data "template_file" "install_calico" {
 template = file("${path.module}/scripts/install_calico.template.sh")

 vars = {
   calico_version     = var.calico.calico_version
   number_of_nodes    = local.total_nodes
   pod_cidr           = var.oke_cluster.cluster_options_kubernetes_network_config_pods_cidr
   number_of_replicas = min(20,max((local.total_nodes)/200,3))
   user_ocid          = var.oke_identity.user_ocid
 }

 count = var.calico.install_calico == true   ? 1 : 0
}

resource null_resource "install_calico" {
 connection {
   host        = var.oke_bastion.bastion_public_ip
   private_key = file(var.oke_ssh_keys.ssh_private_key_path)
   timeout     = "40m"
   type        = "ssh"
   user        = var.oke_bastion.image_operating_system == "Canonical Ubuntu"   ? "ubuntu" : "opc"
 }

 depends_on = ["null_resource.install_kubectl_bastion", "null_resource.write_kubeconfig_bastion"]

 provisioner "file" {
   content     = data.template_file.install_calico[0].rendered
   destination = "~/install_calico.sh"
 }

 provisioner "remote-exec" {
   inline = [
     "chmod +x $HOME/install_calico.sh",
     "$HOME/install_calico.sh",
     "rm -f $HOME/install_calico.sh"
   ]
 }

 count = var.oke_bastion.create_bastion == true  && var.calico.install_calico == true   ? 1 : 0
}

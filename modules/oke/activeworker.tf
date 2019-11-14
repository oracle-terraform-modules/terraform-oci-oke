# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# data "template_file" "check_worker_node_status" {
#   template = file("${path.module}/scripts/is_worker_active.py")

#   vars = {
#     cluster_id     = oci_containerengine_cluster.k8s_cluster.id
#     compartment_id = var.oke_identity.compartment_id
#     region         = var.oke_general.region
#   }
#   count = var.oke_admin.admin_enabled == true ? 1 : 0
# }

# resource null_resource "is_worker_active" {
#   connection {
#     host        = var.oke_admin.admin_private_ip
#     private_key = file(var.oke_ssh_keys.ssh_private_key_path)
#     timeout     = "40m"
#     type        = "ssh"
#     user        = "opc"

#     bastion_host        = var.oke_admin.bastion_public_ip
#     bastion_user        = "opc"
#     bastion_private_key = file(var.oke_ssh_keys.ssh_private_key_path)
#   }

#   depends_on = ["oci_containerengine_node_pool.nodepools"]

#   provisioner "file" {
#     content     = data.template_file.check_worker_node_status[0].rendered
#     destination = "~/is_worker_active.py"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "chmod +x $HOME/is_worker_active.py",
#       "while [ ! -f $HOME/node.active ]; do $HOME/is_worker_active.py; sleep 10; done",
#     ]
#   }

#   count = var.oke_admin.admin_enabled == true ? 1 : 0
# }

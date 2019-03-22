# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

# data "template_file" "check_worker_node_status" {
#   template = "${file("${path.module}/scripts/is_worker_active.py")}"

#   vars {
#     compartment_id = "${var.compartment_ocid}"
#   }
# }

# resource null_resource "write_check_worker_script_ad1" {
#   connection {
#     type        = "ssh"
#     host        = "${var.bastion_public_ips["ad1"]}"
#     user        = "opc"
#     private_key = "${file(var.ssh_private_key_path)}"
#     timeout     = "40m"
#   }

#   provisioner "file" {
#     content     = "${data.template_file.check_worker_node_status.rendered}"
#     destination = "/home/opc/is_worker_active.py"
#   }

#   count = "${var.availability_domains["bastion_ad1"] == "true"   ? 1 : 0}"
# }

# resource null_resource "is_worker_active_ad1" {
#   depends_on = ["null_resource.write_check_worker_script_ad1", "oci_containerengine_cluster.k8s_cluster"]

#   connection {
#     type        = "ssh"
#     host        = "${var.bastion_public_ips["ad1"]}"
#     user        = "opc"
#     private_key = "${file(var.ssh_private_key_path)}"
#     timeout     = "40m"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "chmod +x /home/opc/is_worker_active.py",
#       "while [ ! -f /home/opc/node.active ]; do /home/opc/is_worker_active.py; sleep 10; done",
#     ]
#   }

#   count = "${var.availability_domains["bastion_ad1"] == "true"  ? 1 : 0}"
# }

# resource null_resource "write_check_worker_script_ad2" {
#   connection {
#     type        = "ssh"
#     host        = "${var.bastion_public_ips["ad2"]}"
#     user        = "opc"
#     private_key = "${file(var.ssh_private_key_path)}"
#     timeout     = "40m"
#   }

#   provisioner "file" {
#     content     = "${data.template_file.check_worker_node_status.rendered}"
#     destination = "/home/opc/is_worker_active.py"
#   }

#   count = "${var.availability_domains["bastion_ad2"] == "true"  ? 1 : 0}"
# }

# resource null_resource "is_worker_active_ad2" {
#   depends_on = ["null_resource.write_check_worker_script_ad2", "oci_containerengine_cluster.k8s_cluster"]

#   connection {
#     type        = "ssh"
#     host        = "${var.bastion_public_ips["ad2"]}"
#     user        = "opc"
#     private_key = "${file(var.ssh_private_key_path)}"
#     timeout     = "40m"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "chmod +x /home/opc/is_worker_active.py",
#       "while [ ! -f /home/opc/node.active ]; do /home/opc/is_worker_active.py; sleep 10; done",
#     ]
#   }

#   count = "${var.availability_domains["bastion_ad2"] == "true"  ? 1 : 0}"
# }

# resource null_resource "write_check_worker_script_ad3" {
#   connection {
#     type        = "ssh"
#     host        = "${var.bastion_public_ips["ad3"]}"
#     user        = "opc"
#     private_key = "${file(var.ssh_private_key_path)}"
#     timeout     = "40m"
#   }

#   provisioner "file" {
#     content     = "${data.template_file.check_worker_node_status.rendered}"
#     destination = "/home/opc/is_worker_active.py"
#   }

#   count = "${var.availability_domains["bastion_ad3"] == "true" ? 1 : 0}"
# }

# resource null_resource "is_worker_active_ad3" {
#   depends_on = ["null_resource.write_check_worker_script_ad3", "oci_containerengine_cluster.k8s_cluster"]

#   connection {
#     type        = "ssh"
#     host        = "${var.bastion_public_ips["ad3"]}"
#     user        = "opc"
#     private_key = "${file(var.ssh_private_key_path)}"
#     timeout     = "40m"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "chmod +x /home/opc/is_worker_active.py",
#       "while [ ! -f /home/opc/node.active ]; do /home/opc/is_worker_active.py; sleep 10; done",
#     ]
#   }

#   count = "${var.availability_domains["bastion_ad3"] == "true"  ? 1 : 0}"
# }

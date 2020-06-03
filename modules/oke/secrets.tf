# # Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# # Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

 data "template_file" "secret" {
   template = file("${path.module}/scripts/secret.py")

   vars = {
     compartment_id  = var.oke_identity.compartment_id
     region          = var.oke_general.region
     secret_id       = var.oke_ocir.secret_id
     email_address   = var.oke_ocir.email_address
     region_registry = var.oke_ocir.ocir_urls[var.oke_general.region]
     tenancy_name    = var.oke_ocir.tenancy_name
     username        = var.oke_ocir.username

   }
   count = var.oke_admin.admin_enabled == true && var.oke_admin.admin_instance_principal == true && var.oke_ocir.secret_id != null ? 1 : 0
 }

 resource null_resource "secret" {
   triggers = {
    secret_id = var.oke_ocir.secret_id
  }
   connection {
     host        = var.oke_admin.admin_private_ip
     private_key = file(var.oke_ssh_keys.ssh_private_key_path)
     timeout     = "40m"
     type        = "ssh"
     user        = "opc"

     bastion_host        = var.oke_admin.bastion_public_ip
     bastion_user        = "opc"
     bastion_private_key = file(var.oke_ssh_keys.ssh_private_key_path)
   }

   depends_on = [null_resource.write_kubeconfig_on_admin]

   provisioner "file" {
     content     = data.template_file.secret[0].rendered
     destination = "~/secret.py"
   }

   provisioner "remote-exec" {
     inline = [
       "chmod +x $HOME/secret.py",
       "$HOME/secret.py",
       "sleep 10",
       "rm -f $HOME/secret.py"
     ]
   }

   count = var.oke_admin.admin_enabled == true && var.oke_admin.admin_instance_principal == true && var.oke_ocir.secret_id != null ? 1 : 0
 }

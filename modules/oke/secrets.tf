# # Copyright 2017, 2021 Oracle Corporation and/or affiliates.  All rights reserved.
# # Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# data "template_file" "secret" {
#   template = file("${path.module}/scripts/secret.py")

#   vars = {
#     compartment_id = var.compartment_id
#     region         = var.region

#     email_address     = var.email_address
#     region_registry   = var.ocir_urls[var.region]
#     secret_id         = var.secret_id
#     secret_name       = var.secret_name
#     tenancy_namespace = data.oci_objectstorage_namespace.object_storage_namespace.namespace
#     username          = var.username

#   }
#   count = local.post_provisioning_ops == true && var.secret_id != "none" ? 1 : 0
# }

locals {
  secret_template = templatefile("${path.module}/scripts/secret.py",
    {
      compartment_id = var.compartment_id
      region         = var.region

      email_address     = var.email_address
      region_registry   = var.ocir_urls[var.region]
      secret_id         = var.secret_id
      secret_name       = var.secret_name
      tenancy_namespace = data.oci_objectstorage_namespace.object_storage_namespace.namespace
      username          = var.username
    }
  )
}

resource "null_resource" "secret" {
  triggers = {
    secret_id = var.secret_id
  }
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

  depends_on = [null_resource.write_kubeconfig_on_operator]

  provisioner "file" {
    # content     = data.template_file.secret[0].rendered
    content     = local.secret_template
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

  count = local.post_provisioning_ops == true && var.secret_id != "none" ? 1 : 0
}

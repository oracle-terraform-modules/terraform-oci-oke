# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Retrieve object storage namespace for creating ocir secret
data "oci_objectstorage_namespace" "object_storage_namespace" {}

locals {
  secret_template = templatefile("${path.module}/scripts/secret.template.sh", {
    compartment_id = var.compartment_id
    region         = var.region

    email_address     = var.email_address
    region_registry   = join("", [var.region, ".ocir.io"])
    secret_id         = var.secret_id
    secret_name       = var.secret_name
    secret_namespace  = var.secret_namespace
    tenancy_namespace = data.oci_objectstorage_namespace.object_storage_namespace.namespace
    username          = var.username
    }
  )
}

resource "null_resource" "secret" {
  triggers = {
    always_run = timestamp()
  }
  connection {
    host        = var.operator_private_ip
    private_key = var.ssh_private_key
    timeout     = "40m"
    type        = "ssh"
    user        = var.operator_user

    bastion_host        = var.bastion_public_ip
    bastion_user        = var.bastion_user
    bastion_private_key = var.ssh_private_key
  }

  depends_on = [null_resource.write_kubeconfig_on_operator]

  provisioner "file" {
    content     = local.secret_template
    destination = "/home/${var.operator_user}/secret.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "if [ -f \"$HOME/secret.sh\" ]; then bash \"$HOME/secret.sh\"; rm -f \"$HOME/secret.sh\";fi",
      "sleep 10",
    ]
  }

  count = coalesce(var.secret_id, "none") != "none" ? 1 : 0
}

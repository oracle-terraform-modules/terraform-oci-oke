# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Retrieve object storage namespace for secret
data "oci_objectstorage_namespace" "object_storage_namespace" {
  count = coalesce(var.ocir_secret_id, "none") != "none" ? 1 : 0
}

locals {
  oci_secret_query = "'data.\"secret-bundle-content\".content'"
  oci_secret_get = format(
    "oci secrets secret-bundle get --raw-output --secret-id %s --query %s | base64 -d",
    coalesce(var.ocir_secret_id, "none"), local.oci_secret_query,
  )

  region_registry   = "${var.region}.ocir.io"
  tenancy_namespace = one(data.oci_objectstorage_namespace.object_storage_namespace[*].namespace)
}

resource "null_resource" "ocir_secret" {
  count    = coalesce(var.ocir_secret_id, "none") != "none" ? 1 : 0
  triggers = { always_run = timestamp() }

  connection {
    bastion_host        = var.bastion_host
    bastion_user        = var.bastion_user
    bastion_private_key = var.ssh_private_key
    host                = var.operator_host
    user                = var.operator_user
    private_key         = var.ssh_private_key
    timeout             = "40m"
    type                = "ssh"
  }

  provisioner "remote-exec" {
    inline = formatlist("%s --dry-run=client -o yaml | kubectl apply -f -", [
      format("kubectl create ns %s", var.ocir_secret_namespace),
      format("kubectl create secret docker-registry %s",
        join(" ", [
          var.ocir_secret_name,
          format("-n %s", var.ocir_secret_namespace),
          format("--docker-server=%s", local.region_registry),
          format("--docker-ocir_username=%s/%s", join("/", compact([local.tenancy_namespace, var.ocir_username]))),
          format("--docker-email=%s", var.ocir_email_address),
          format("--docker-password=%s", local.oci_secret_get)
        ])
      ),
    ])
  }

  lifecycle {
    precondition {
      condition = alltrue([
        local.region_registry != null,
        local.tenancy_namespace != null,
        var.ocir_email_address != null,
        var.ocir_secret_name != null,
        var.ocir_secret_namespace != null,
        var.ocir_username != null,
      ])
      error_message = "Missing required configuration for OCIR; check variables."
    }
  }
}

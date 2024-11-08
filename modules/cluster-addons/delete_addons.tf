# Copyright (c) 2017, 2024 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  remove_addon_command = "oci ce cluster disable-addon --addon-name %s --cluster-id %s --is-remove-existing-add-on %t --force"
  remove_addons_defaults = {
    custom_commands      = []
    remove_k8s_resources = true
  }
  remove_addons_with_defaults = { for addon_name, addon_value in var.cluster_addons_to_remove :
    addon_name => merge(local.remove_addons_defaults, addon_value)
  }
}

resource "null_resource" "remove_addons" {
  for_each   = var.operator_enabled ? local.remove_addons_with_defaults : {}
  depends_on = [oci_containerengine_addon.primary_addon, oci_containerengine_addon.secondary_addon]

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
    inline = concat(
      [
        "echo 'Removing ${each.key} addon'",
        format(local.remove_addon_command, each.key, var.cluster_id, lookup(each.value, "remove_k8s_resources"))
      ],
      lookup(each.value, "custom_commands")
    )
  }

  lifecycle {
    precondition {
      condition     = contains(local.supported_addons, each.key)
      error_message = <<-EOT
      The addon ${each.key} is not supported.
      The list of supported addons is: ${join(", ", local.supported_addons)}.
      EOT
    }
  }
}
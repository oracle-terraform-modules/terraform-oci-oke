# Copyright 2017, 2021 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

terraform {
  required_providers {
    oci = {
      source = "hashicorp/oci"
      # pass oci home region provider explicitly for identity operations
      configuration_aliases = [oci.home]
    }
  }
  required_version = ">= 1.0.0"
}

resource "oci_identity_policy" "operator_instance_principal_dynamic_group" {
  provider       = oci.home
  compartment_id = var.tenancy_id
  description    = "policy to allow operator host to manage dynamic group"
  name           = var.label_prefix == "none" ? "operator-instance-principal-dynamic-group-${substr(uuid(), 0, 8)}" : "${var.label_prefix}-operator-instance-principal-dynamic-group-${substr(uuid(), 0, 8)}"
  statements     = ["Allow dynamic-group ${var.operator_dynamic_group} to use dynamic-groups in tenancy"]
  count          = (var.use_encryption == true && var.create_bastion_host == true && var.enable_operator_instance_principal == true) ? 1 : 0
}

resource "null_resource" "update_dynamic_group" {
  triggers = {
    cluster_id = var.cluster_id
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

  depends_on = [oci_identity_policy.operator_instance_principal_dynamic_group]

  provisioner "file" {
    content     = local.update_dynamic_group_template
    destination = "~/update_dynamic_group.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x $HOME/update_dynamic_group.sh",
      "$HOME/update_dynamic_group.sh",
      "rm -f $HOME/update_dynamic_group.sh"
    ]
  }

  count = (var.use_encryption == true && var.create_bastion_host == true && var.bastion_state == "RUNNING" && var.enable_operator_instance_principal == true) ? 1 : 0
}

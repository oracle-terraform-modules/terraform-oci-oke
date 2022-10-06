# Copyright 2017, 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
      # pass oci home region provider explicitly for identity operations
      configuration_aliases = [oci.home]
      version               = ">= 4.67.3"
    }
  }
  required_version = ">= 1.0.0"
}

locals {
  create_operator_dynamic_group_policy = (var.use_cluster_encryption == true && var.create_policies == true && var.create_bastion_host == true && var.enable_operator_instance_principal == true)
}

resource "random_id" "dynamic_group_suffix" {
  keepers = {
    # Generate a new suffix only when variables are changed
    label_prefix         = local.dynamic_group_prefix
    tenancy_id           = var.tenancy_id
  }

  byte_length = 8
}

# TODO Move to Operator module
resource "oci_identity_policy" "operator_use_dynamic_group_policy" {
  provider       = oci.home
  compartment_id = random_id.dynamic_group_suffix.keepers.tenancy_id
  description    = "policy to allow operator host to manage dynamic group"
  name           = join("-", compact([
    random_id.dynamic_group_suffix.keepers.label_prefix,
    "operator-instance-principal-dynamic-group",
    random_id.dynamic_group_suffix.hex
  ]))
  statements     = ["Allow dynamic-group ${var.operator_dynamic_group} to use dynamic-groups in tenancy"]
  count          = (local.create_operator_dynamic_group_policy == true) ? 1 : 0
}

# 30s delay to allow policies to take effect globally
resource "time_sleep" "wait_30_seconds" {
  depends_on = [oci_identity_policy.operator_use_dynamic_group_policy]

  create_duration = "30s"
  count          = (local.create_operator_dynamic_group_policy == true) ? 1 : 0
}

resource "null_resource" "update_dynamic_group" {

  connection {
    host        = var.operator_private_ip
    private_key = local.ssh_private_key
    timeout     = "40m"
    type        = "ssh"
    user        = var.operator_user

    bastion_host        = var.bastion_public_ip
    bastion_user        = var.bastion_user
    bastion_private_key = local.ssh_private_key
  }

  depends_on = [time_sleep.wait_30_seconds]

  provisioner "file" {
    content     = local.update_dynamic_group_template
    destination = "/home/opc/update_dynamic_group.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "if [ -f \"$HOME/update_dynamic_group.sh\" ]; then bash $HOME/update_dynamic_group.sh; rm -f \"$HOME/update_dynamic_group.sh\";fi",
    ]
  }

  count = (local.create_operator_dynamic_group_policy && var.bastion_state == "RUNNING" ) ? 1 : 0
}

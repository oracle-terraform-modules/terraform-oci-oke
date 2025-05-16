# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config.html
data "cloudinit_config" "bastion" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    # https://cloudinit.readthedocs.io/en/latest/reference/examples.html#run-commands-on-first-boot
    content = <<-EOT
    runcmd:
    - ${format("dnf config-manager --disable ol%v_addons --disable ol%v_appstream", var.bastion_image_os_version, var.bastion_image_os_version)}
    EOT
  }

  part {
    content_type = "text/cloud-config"
    # https://cloudinit.readthedocs.io/en/latest/reference/modules.html#package-update-upgrade-install
    content  = jsonencode({ package_upgrade = var.upgrade })
    filename = "10-packages.yml"
  }

  part {
    content_type = "text/cloud-config"
    # https://cloudinit.readthedocs.io/en/latest/reference/modules.html#timezone
    content  = jsonencode({ timezone = var.timezone })
    filename = "10-timezone.yml"
  }

  part {
    content_type = "text/cloud-config"
    # https://cloudinit.readthedocs.io/en/latest/reference/modules.html#package-update-upgrade-install
    content  = jsonencode({ users = ["default", var.user] })
    filename = "10-user.yml"
  }
}

resource "null_resource" "await_cloudinit" {
  count = var.await_cloudinit ? 1 : 0
  connection {
    host        = oci_core_instance.bastion.public_ip
    user        = var.user
    private_key = var.ssh_private_key
    timeout     = "40m"
    type        = "ssh"
  }

  lifecycle {
    replace_triggered_by = [oci_core_instance.bastion]
  }

  provisioner "remote-exec" {
    inline = ["cloud-init status --wait &> /dev/null"]
  }
}
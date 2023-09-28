# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  # https://cloudinit.readthedocs.io/en/latest/explanation/format.html#mime-multi-part-archive
  default_cloud_init_content_type = "text/x-shellscript"

  # https://canonical-cloud-init.readthedocs-hosted.com/en/latest/reference/merging.html
  default_cloud_init_merge_type = "list(append)+dict(no_replace,recurse_list)+str(append)"
}

# https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config.html
data "cloudinit_config" "operator" {
  gzip          = true
  base64_encode = true

  # Repository/package installation
  part {
    content_type = "text/cloud-config"
    content = jsonencode({
      # https://cloudinit.readthedocs.io/en/latest/reference/modules.html#package-update-upgrade-install
      package_update  = true
      package_upgrade = var.upgrade
      packages = compact([
        "git",
        "jq",
        "kubectl",
        "python3-oci-cli",
        var.install_helm ? "helm" : null,
      ])
      yum_repos = {
        ol8_developer_EPEL = {
          name     = "Oracle Linux $releasever EPEL Packages for Development ($basearch)"
          baseurl  = "https://yum$ociregion.$ocidomain/repo/OracleLinux/OL8/developer/EPEL/$basearch/"
          gpgkey   = "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-oracle"
          gpgcheck = true
          enabled  = true
        }
        ol8_olcne17 = {
          name     = "Oracle Linux Cloud Native Environment 1.7 ($basearch)"
          baseurl  = "https://yum$ociregion.$ocidomain/repo/OracleLinux/OL8/olcne17/$basearch/"
          gpgkey   = "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-oracle"
          gpgcheck = true
          enabled  = true
        }
        ol8_developer_olcne = {
          name     = "Developer Preview for Oracle Linux Cloud Native Environment ($basearch)"
          baseurl  = "https://yum$ociregion.$ocidomain/repo/OracleLinux/OL8/developer/olcne/$basearch/"
          gpgkey   = "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-oracle"
          gpgcheck = true
          enabled  = false
        }
      }
    })
    filename   = "10-packages.yml"
    merge_type = local.default_cloud_init_merge_type
  }

  # Set timezone
  part {
    # https://cloudinit.readthedocs.io/en/latest/reference/modules.html#timezone
    content_type = "text/cloud-config"
    content      = jsonencode({ timezone = var.timezone })
    filename     = "10-timezone.yml"
  }

  # Create configured user
  part {
    content_type = "text/cloud-config"
    # https://cloudinit.readthedocs.io/en/latest/reference/modules.html#users-and-groups
    content  = jsonencode({ users = ["default", var.user] })
    filename = "10-user.yml"
  }

  # Expand root filesystem to fill available space on volume
  part {
    content_type = "text/cloud-config"
    content = jsonencode({
      # https://cloudinit.readthedocs.io/en/latest/reference/modules.html#growpart
      growpart = {
        mode                     = "auto"
        devices                  = ["/"]
        ignore_growroot_disabled = false
      }

      # https://cloudinit.readthedocs.io/en/latest/reference/modules.html#resizefs
      resize_rootfs = true

      # Resize logical LVM root volume when utility is present
      bootcmd = ["if [[ -f /usr/libexec/oci-growfs ]]; then /usr/libexec/oci-growfs -y; fi"]
    })
    filename   = "10-growpart.yml"
    merge_type = local.default_cloud_init_merge_type
  }

  # kubectx/kubens installation
  dynamic "part" {
    for_each = var.install_kubectx ? [1] : []
    content {
      content_type = "text/cloud-config"
      content = jsonencode({
        runcmd = [
          "git clone https://github.com/ahmetb/kubectx /opt/kubectx",
          "ln -s /opt/kubectx/kubectx /usr/bin/kubectx",
          "ln -s /opt/kubectx/kubens /usr/bin/kubens",
        ]
      })
      filename   = "20-kubectx.yml"
      merge_type = local.default_cloud_init_merge_type
    }
  }

  # Optional Helm installation bashrc
  dynamic "part" {
    for_each = var.install_helm ? [1] : []
    content {
      content_type = "text/cloud-config"
      content = jsonencode({
        # https://cloudinit.readthedocs.io/en/latest/reference/modules.html#write-files
        write_files = [
          {
            content = <<-EOT
              source <(helm completion bash)
              alias h='helm'
            EOT
            path    = "/tmp/helm.bashrc" # see 30-bashrc.yml for final move
          },
        ]
      })
      filename   = "20-helm.bashrc.yml"
      merge_type = local.default_cloud_init_merge_type
    }
  }

  # Optional k9s installation
  dynamic "part" {
    for_each = var.install_k9s ? [1] : []
    content {
      content_type = "text/cloud-config"
      content = jsonencode({
        runcmd = [
          "curl -LO https://github.com/derailed/k9s/releases/download/v0.27.2/k9s_Linux_amd64.tar.gz",
          "tar -xvzf k9s_Linux_amd64.tar.gz && mv ./k9s /usr/bin/k9s",
        ]
      })
      filename   = "20-k9s.yml"
      merge_type = local.default_cloud_init_merge_type
    }
  }

  # Write user bashrc to filesystem
  part {
    content_type = "text/cloud-config"
    content = jsonencode({
      # https://cloudinit.readthedocs.io/en/latest/reference/modules.html#write-files
      write_files = [
        {
          content = <<-EOT
            export OCI_CLI_AUTH=instance_principal
            export TERM=xterm-256color
            source <(kubectl completion bash)
            alias k='kubectl'
            alias ktx='kubectx'
            alias kns='kubens'
          EOT
          path    = "/tmp/user.bashrc" # see 30-home.yml for final move
        },
      ]
    })
    filename   = "20-bashrc.yml"
    merge_type = local.default_cloud_init_merge_type
  }

  # Write user kubeconfig to filesystem
  part {
    content_type = "text/cloud-config"
    content = jsonencode({
      # https://cloudinit.readthedocs.io/en/latest/reference/modules.html#write-files
      write_files = [
        {
          content = var.kubeconfig
          path    = "/tmp/kubeconfig" # see 30-home.yml for final move
        },
      ]
    })
    filename   = "20-kubeconfig.yml"
    merge_type = local.default_cloud_init_merge_type
  }

  # Bug w/ write_files defer: parent directory created as root if not present.
  # https://github.com/canonical/cloud-init/pull/916#issuecomment-1254732400
  # Or: defer not supported on older versions of cloud-init.
  # Created in tmp first and moved into user's home directory using runcmd.
  part {
    content_type = "text/cloud-config"
    content = jsonencode({
      runcmd = [
        "cat /tmp/*.bashrc >> /home/${var.user}/.bashrc && rm /tmp/*.bashrc",
        "chmod 600 /home/${var.user}/.bashrc",
        "mkdir -p /home/${var.user}/.kube",
        "mv /tmp/kubeconfig /home/${var.user}/.kube/config",
        "chmod 700 /home/${var.user}/.kube",
        "chmod 600 /home/${var.user}/.kube/config",
        "chown -R ${var.user}:${var.user} /home/${var.user}",
      ]
    })
    filename   = "30-home.yml"
    merge_type = local.default_cloud_init_merge_type
  }

  # Include custom cloud init MIME parts
  dynamic "part" {
    for_each = var.cloud_init
    iterator = part
    content {
      # Load content from file if local path, attempt base64 decode, or use raw value
      content = contains(keys(part.value), "content") ? (
        fileexists(lookup(part.value, "content")) ? file(lookup(part.value, "content"))
        : try(base64decode(lookup(part.value, "content")), lookup(part.value, "content"))
      ) : ""
      content_type = lookup(part.value, "content_type", local.default_cloud_init_content_type)
      filename     = lookup(part.value, "filename", null)
      merge_type   = lookup(part.value, "merge_type", local.default_cloud_init_merge_type)
    }
  }

  lifecycle {
    precondition {
      condition     = alltrue([for c in var.cloud_init : trimspace(lookup(c, "content", "")) != ""])
      error_message = <<-EOT
      Each operator cloud_init map entry must include a non-empty 'content' field.
      See https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config.html.
      var.cloud_init: ${try(jsonencode(var.cloud_init), "invalid")}
      EOT
    }

    precondition {
      condition = alltrue([for c in var.cloud_init :
        length(regexall("^text/[a-z-]*$", trimspace(lookup(c, "content_type", local.default_cloud_init_content_type)))) > 0
      ])
      error_message = <<-EOT
      Each operator cloud_init map entry must include a 'content_type' field prefixed with 'text/'.
      See https://cloudinit.readthedocs.io/en/latest/explanation/format.html#mime-multi-part-archive.
      var.cloud_init: ${try(jsonencode(var.cloud_init), "invalid")}
      EOT
    }
  }
}

resource "null_resource" "await_cloudinit" {
  connection {
    bastion_host        = var.bastion_host
    bastion_user        = var.bastion_user
    bastion_private_key = var.ssh_private_key
    host                = oci_core_instance.operator.private_ip
    user                = var.user
    private_key         = var.ssh_private_key
    timeout             = "40m"
    type                = "ssh"
  }

  lifecycle {
    replace_triggered_by = [oci_core_instance.operator]
  }

  provisioner "remote-exec" {
    inline = ["cloud-init status --wait &> /dev/null"]
  }
}

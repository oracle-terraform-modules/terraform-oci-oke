# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  # https://cloudinit.readthedocs.io/en/latest/explanation/format.html#mime-multi-part-archive
  default_cloud_init_content_type = "text/x-shellscript"

  # https://canonical-cloud-init.readthedocs-hosted.com/en/latest/reference/merging.html
  default_cloud_init_merge_type = "list(append)+dict(no_replace,recurse_list)+str(append)"

  baserepo        = "ol${var.operator_image_os_version}"
  developer_EPEL  = "${local.baserepo}_developer_EPEL"
  olcne19         = "${local.baserepo}_olcne19"
  developer_olcne = "${local.baserepo}_developer_olcne"
  arch_amd        = "amd64"
  arch_arm        = "aarch64"
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
        "python3-oci-cli",
        "golang",
        var.install_helm ? "helm" : null,
        var.install_istioctl ? "istio-istioctl" : null,
        var.install_kubectl_from_repo ? "kubectl" : null,
      ])
      yum_repos = {
        "${local.developer_EPEL}" = {
          name     = "Oracle Linux $releasever EPEL Packages for Development ($basearch)"
          baseurl  = "https://yum$ociregion.$ocidomain/repo/OracleLinux/OL${var.operator_image_os_version}/developer/EPEL/$basearch/"
          gpgkey   = "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-oracle"
          gpgcheck = true
          enabled  = true
        }
        "${local.olcne19}" = {
          name     = "Oracle Linux Cloud Native Environment 1.8 ($basearch)"
          baseurl  = "https://yum$ociregion.$ocidomain/repo/OracleLinux/OL${var.operator_image_os_version}/olcne19/$basearch/"
          gpgkey   = "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-oracle"
          gpgcheck = true
          enabled  = true
        }
        "${local.developer_olcne}" = {
          name     = "Developer Preview for Oracle Linux Cloud Native Environment ($basearch)"
          baseurl  = "https://yum$ociregion.$ocidomain/repo/OracleLinux/OL${var.operator_image_os_version}/developer/olcne/$basearch/"
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


  # OCI CLI installation from repo
  dynamic "part" {
    for_each = var.install_oci_cli_from_repo ? [1] : []
    content {
      content_type = "text/cloud-config"
      content = jsonencode({
        runcmd = [
          "curl -LO https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh",
          "su -c 'bash /install.sh --accept-all-defaults' - ${var.user}",
        ]
      })
      filename   = "20-oci_cli_from_repo.yml"
      merge_type = local.default_cloud_init_merge_type
    }
  }

  # kubectl installation
  dynamic "part" {
    for_each = var.install_kubectl_from_repo ? [1] : []
    content {
      content_type = "text/cloud-config"
      content = jsonencode({
        runcmd = [
          "CLI_ARCH='${local.arch_amd}'",
          "if [ \"$(uname -m)\" = ${local.arch_arm} ]; then CLI_ARCH='arm64'; fi",
          "curl -LO https://dl.k8s.io/release/${var.kubernetes_version}/bin/linux/$CLI_ARCH/kubectl",
          "install -o root -g root -m 0755 kubectl /usr/bin/kubectl",
        ]
      })
      filename   = "20-kubectl.yml"
      merge_type = local.default_cloud_init_merge_type
    }
  }

  # k8sgpt installation
  dynamic "part" {
    for_each = var.install_k8sgpt ? [1] : []
    content {
      content_type = "text/cloud-config"
      content = jsonencode({
        runcmd = [
          "CLI_ARCH='${local.arch_amd}'",
          "if [ \"$(uname -m)\" = ${local.arch_arm} ]; then CLI_ARCH='arm64'; fi",
          "if [ -f /etc/os-release ]; then os_id=$(grep '^ID=' /etc/os-release | awk -F= '{print $2}' | tr -d '\"'); fi",
          "if [ \"$os_id\" == \"ubuntu\" ]; then curl -LO https://github.com/k8sgpt-ai/k8sgpt/releases/latest/download/k8sgpt_$CLI_ARCH.deb; dpkg -i k8sgpt_$CLI_ARCH.deb; rm k8sgpt_$CLI_ARCH.deb; fi",
          "if [ \"$os_id\" == \"ol\" ]; then while fuser /var/lib/rpm/.rpm.lock >/dev/null 2>&1; do sleep 5; done; rpm -ivh https://github.com/k8sgpt-ai/k8sgpt/releases/latest/download/k8sgpt_$CLI_ARCH.rpm; fi"
        ]
      })
      filename   = "20-k8sgpt.yml"
      merge_type = local.default_cloud_init_merge_type
    }
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

  # Helm installation from repo
  dynamic "part" {
    for_each = var.install_helm_from_repo ? [1] : []
    content {
      content_type = "text/cloud-config"
      content = jsonencode({
        runcmd = [
          "curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3",
          "chmod 700 get_helm.sh",
          "./get_helm.sh",
        ]
      })
      filename   = "20-helm_from_repo.yml"
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
          "curl -LO https://github.com/derailed/k9s/releases/download/v0.40.5/k9s_Linux_amd64.tar.gz",
          "tar -xvzf k9s_Linux_amd64.tar.gz && mv ./k9s /usr/bin/k9s",
        ]
      })
      filename   = "20-k9s.yml"
      merge_type = local.default_cloud_init_merge_type
    }
  }

  # Optional cilium cli installation
  dynamic "part" {
    for_each = var.install_cilium ? [1] : []
    content {
      content_type = "text/cloud-config"
      content = jsonencode({
        runcmd = [
          "CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/master/stable.txt)",
          "CLI_ARCH='${local.arch_amd}'",
          "if [ \"$(uname -m)\" = ${local.arch_arm} ]; then CLI_ARCH='arm64'; fi",
          "curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/$CILIUM_CLI_VERSION/cilium-linux-$CLI_ARCH.tar.gz",
          "tar xzvfC cilium-linux-$CLI_ARCH.tar.gz /usr/local/bin"
        ]
      })
      filename   = "20-cilium.yml"
      merge_type = local.default_cloud_init_merge_type
    }
  }

  # stern installation
  dynamic "part" {
    for_each = var.install_stern ? [1] : []
    content {
      content_type = "text/cloud-config"
      content = jsonencode({
        runcmd = [
          "go install github.com/stern/stern@v1.30",
          "mv $HOME/go/bin/stern /usr/local/bin/",
          "ln -s /usr/local/bin/stern /usr/bin/stern"
        ]
      })
      filename   = "20-stern.yml"
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
            export OCI_PYTHON_SDK_NO_SERVICE_IMPORTS=True
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
        try(fileexists(lookup(part.value, "content")), false) ? file(lookup(part.value, "content"))
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
  count = var.await_cloudinit ? 1 : 0
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
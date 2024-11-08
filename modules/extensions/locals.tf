# Copyright (c)  2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  yaml_manifest_path           = "/home/${var.operator_user}/yaml"
  kubectl                      = "set -o pipefail; kubectl"
  helm                         = "set -o pipefail; helm"
  kubectl_apply_ns_file        = "${local.kubectl} apply -n %s -f %s"
  kubectl_apply_file           = "${local.kubectl} apply -f %s"
  kubectl_apply_server_file    = "${local.kubectl} apply --force-conflicts=true --server-side -f %s"
  kubectl_apply_server_ns_file = "${local.kubectl} apply -n %s --force-conflicts=true --server-side -f %s"
  kubectl_create_missing_ns    = "${local.kubectl} create ns %s --dry-run=client -o yaml | kubectl apply -f -"
  selector_linux               = { "kubernetes.io/os" = "linux" }
  output_log                   = "bash -c \"%s | tee >(systemd-cat -t %s -p info)\""
  helm_upgrade_install         = "${local.helm} upgrade --install %s %s --repo %s --version %s --namespace %s --create-namespace --skip-crds -f %s"
}

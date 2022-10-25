#!/usr/bin/env bash
# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl
# shellcheck disable=SC1083,SC2309,SC2125,SC2154,SC2157,SC2034,SC2242 # Ignore templated/escaped/unused file variables
set -o pipefail

echo "${apiserver_host}"  > "/etc/oke/oke-apiserver" # templated by Terraform
echo "${cluster_ca_cert}" | base64 -d > "/etc/kubernetes/ca.crt" # templated by Terraform

function run_oke_init() { # Initialize OKE worker node
  if command -v oke-init-systemd &>/dev/null; then oke-init-systemd; return
  elif [[ -f /etc/oke/oke-install.sh ]]; then
    time bash /etc/oke/oke-install.sh \
      --apiserver-endpoint "$(get_apiserver_host)" \
      --kubelet-ca-cert "$(get_kubelet_client_ca)" \
      --cluster-dns "$(get_cluster_dns)" \
      --kubelet-extra-args "$(get_kubelet_extra_args)"
  else # Retrieve base64-encoded script content from http, e.g. instance metadata
    local url="$${1:-http://169.254.169.254/opc/v2/instance/metadata/oke_init_script}"
    curl --fail -H "Authorization: Bearer Oracle" -L0 "$${url}" \
      | base64 --decode >/var/run/oke-init.sh && time bash /var/run/oke-init.sh
  fi
}

function expand_rootfs() { # Expand root filesystem
  if [[ -f /usr/libexec/oci-growfs ]]; then /usr/libexec/oci-growfs -y
  elif { command -v growpart && command -v resize2fs; } &>/dev/null; then
    growpart /dev/sda 1 && resize2fs /dev/sda1
  else log "Missing utilities to expand filesystem"; fi
}

run_oke_init; oke_result=$${?}
if [[ "$${oke_result}" -ne 0 ]]; then echo "Error in OKE startup" 1>&2; fi
time expand_rootfs || echo "Error expanding filesystem" 1>&2
exit "$${oke_result}"
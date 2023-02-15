#!/usr/bin/env bash
# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl
# shellcheck disable=SC1091 # Ignore unresolved file path present on base images
set -o pipefail

function run_oke_init() { # Initialize OKE worker node
  if command -v oke-init-systemd &>/dev/null; then oke-init-systemd; return
  elif [[ -f /etc/oke/oke-functions.sh ]] && [[ -f /etc/oke/oke-install.sh ]]; then
    source /etc/oke/oke-functions.sh && bash /etc/oke/oke-install.sh \
      --apiserver-endpoint "$(get_apiserver_host)" \
      --cluster-dns "$(get_cluster_dns)" \
      --kubelet-ca-cert "$(get_kubelet_client_ca)" \
      --kubelet-extra-args "$(get_kubelet_extra_args)"
  else # Retrieve base64-encoded script content from http, e.g. instance metadata
    local oke_init_url='http://169.254.169.254/opc/v2/instance/metadata/oke_init_script'
    curl --fail -H "Authorization: Bearer Oracle" -L0 "${oke_init_url}" \
      | base64 --decode >/var/run/oke-init.sh && bash /var/run/oke-init.sh
  fi
}

time run_oke_init || { echo "Error in OKE startup" 1>&2; exit 1; }
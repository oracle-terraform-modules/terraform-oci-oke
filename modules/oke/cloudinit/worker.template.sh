#!/usr/bin/env bash
# Copyright (c) 2012, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl
# shellcheck disable=SC1083,SC2309,SC2125,SC2154,SC2157,SC2034,SC2242 # Ignore templated/escaped/unused file variables
set -o pipefail

if [[ -f /etc/oke/oke-functions.sh ]]; then
  # shellcheck source=/dev/null # Ignore source outside of project
  source /etc/oke/oke-functions.sh
fi

function run_oke_init() { # Initialize OKE worker node (DO NOT MODIFY)
  if command -v oke-init-systemd &>/dev/null; then oke-init-systemd; return
  else # Retrieve base64-encoded script content from http, e.g. instance metadata
    local url="$${1:-http://169.254.169.254/opc/v2/instance/metadata/oke_init_script}"
    curl --fail -H "Authorization: Bearer Oracle" -L0 "$${url}" \
      | base64 --decode >/var/run/oke-init.sh && time bash /var/run/oke-init.sh
  fi
}

function expand_rootfs() { # Expand root filesystem
  if [[ -f /usr/libexec/oci-growfs ]]; then
    /usr/libexec/oci-growfs -y
  elif { command -v growpart && command -v resize2fs; } &>/dev/null; then
    growpart /dev/sda 1 && resize2fs /dev/sda1
  else echo "Missing utilities to expand root filesystem"; fi
}

run_oke_init; oke_result=$${?}
if [[ "$${oke_result}" -ne 0 ]]; then echo "Error in OKE startup" 1>&2; fi
time expand_rootfs || echo "Error expanding filesystem" 1>&2
timedatectl set-timezone "${worker_timezone}"
touch /var/log/oke.done
exit "$${oke_result}"
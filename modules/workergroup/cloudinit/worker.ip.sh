#!/usr/bin/env bash

set -ex -o pipefail
source /etc/oke/oke-functions.sh

MLX_FUNCTIONS_SH=$${MLX_FUNCTIONS_SH:-/etc/oke/mlx-functions.sh}
if [[ -f "$${MLX_FUNCTIONS_SH}" ]]; then
  source "$${MLX_FUNCTIONS_SH}" || echo "Error importing mlx functions"
fi

function expand_filesystem() {
  echo "Expanding filesystem"
  if command -v oci-growfs &> /dev/null; then
    oci-growfs -y
  elif command -v growpart; then
    growpart /dev/sda 1
    resize2fs /dev/sda1
  else
    echo "Unable to expand filesystem; no utilities exist"
  fi
}

function update_timezone() {
  if (command -v timedatectl &> /dev/null) && [[ -n "${timezone}" ]]; then
   timedatectl set-timezone "${timezone}"
  fi
}

function oke_init() {
  # Write cluster DNS for Kubelet configuration (temporary)
  echo "${cluster_dns}" > /etc/oke/oke-cluster-dns
  export CLUSTER_DNS="${cluster_dns}"
  export APISERVER_ENDPOINT="${apiserver_host}"
  export KUBELET_CA_CERT="${cluster_ca_cert}"

  # Begin OKE worker node configuration
  echo "Starting OKE install"
  bash /etc/oke/oke-install.sh \
    --apiserver-endpoint "${apiserver_host}" \
    --cluster-dns "${cluster_dns}" \
    --kubelet-ca-cert "${cluster_ca_cert}"
  echo "Finished OKE install: $?"
}

function main() {
  update_timezone || echo "Error updating timezone"
  mlx_configure_reboot_if_present "${sriov_num_vfs}" || echo "Error configuring mlx NICs"
  time oke_init || (echo "Error in OKE initialization"; exit 1)
  time expand_filesystem || echo "Error expanding filesystem"
}

main "$@"
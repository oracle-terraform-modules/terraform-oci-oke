#!/bin/bash
# Copyright 2022, Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

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
  # Write cluster DNS for Kubelet configuration
  echo "${cluster_dns}" > /etc/oke/oke-cluster-dns
  export CLUSTER_DNS="${cluster_dns}"
  export APISERVER_ENDPOINT="${apiserver_host}"
  export KUBELET_CA_CERT="${cluster_ca_cert}"

  # Begin OKE worker node configuration
  echo "Starting OKE install"
  if [[ -f /var/run/oke-init.sh ]]; then
    bash -x /var/run/oke-init.sh
  elif [[ -f /etc/oke/oke-install.sh ]]; then
    bash /etc/oke/oke-install.sh \
      --apiserver-endpoint "${apiserver_host}" \
      --cluster-dns "${cluster_dns}" \
      --kubelet-ca-cert "${cluster_ca_cert}"
  fi
  echo "Finished OKE install: $?"
}

# DO NOT MODIFY
curl --fail -H "Authorization: Bearer Oracle" -L0 http://169.254.169.254/opc/v2/instance/metadata/oke_init_script | base64 --decode >/var/run/oke-init.sh

## run oke provisioning script

function main() {
  update_timezone || echo "Error updating timezone"
  mlx_configure_reboot_if_present || echo "Error configuring mlx NICs"
  time oke_init || (echo "Error in OKE initialization"; exit 1)
  time expand_filesystem || echo "Error expanding filesystem"
}

main "$@"
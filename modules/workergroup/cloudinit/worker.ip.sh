#!/usr/bin/env bash
# Copyright 2022, Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

set -ex




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

function oke_init() {
  # Write cluster DNS for Kubelet configuration
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

function configure_functions() {
  # Workaround: startup logging noise
  sed -i 's/set -xe//g' /etc/oke/oke-functions.sh

  # Enable IMDS helper functions for login shell
  echo 'source /etc/oke/oke-functions.sh || true' >> /etc/bash.bashrc
}

function update_timezone() {
  if [[ -n "${timezone}" ]]; then timedatectl set-timezone "${timezone}"; fi
}

function main() {
  configure_functions || echo "Error updating functions"
  source /etc/oke/oke-functions.sh
  update_timezone || echo "Error updating timezone"

  time oke_init
  time expand_filesystem || echo "Error expanding filesystem"
}

main "$@"
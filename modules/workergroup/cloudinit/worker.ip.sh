#!/usr/bin/env bash
# Copyright 2022, Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

set -ex
NUM_OF_VFS="$${NUM_OF_VFS:-2}" # Cluster Networks supports 2 VFs/PF
REBOOT_TRIGGER_FILE=/tmp/.mlx-vf-reboot-required

function enable_sriov() {
  local pci="$${1}"
  (mstconfig -d "$${pci}" query | grep "SRIOV_EN" | grep "True") || \
    (mstconfig -y -d "$${pci}" set SRIOV_EN=1 && touch "$${REBOOT_TRIGGER_FILE}")
}

function configured_num_vfs() {
  local pci="$${1}"
  (mstconfig -d "$${pci}" query | grep "NUM_OF_VFS" | awk '{print $2}') || echo "0"
}

function configure_vfs() {
  local pci="$${1}"
  configured=$(configured_num_vfs "$${pci}")

  if [[ "$${configured}" != "$${NUM_OF_VFS}" ]]; then
    echo "Configuring # of VFs for $${pci} (current: '$${configured}', target: '$${NUM_OF_VFS}')"
    mstconfig -y -d "$${pci}" set NUM_OF_VFS="$${NUM_OF_VFS}"
    touch "$${REBOOT_TRIGGER_FILE}"
  else
    echo "# of VFs already configured"
  fi
}

function get_mlx_pci_pf() {
  (lspci | grep ".*Mellanox.*ConnectX" | grep -v "Virtual" | awk '{print $1}') || true
}




export -f enable_sriov configured_num_vfs configure_vfs  get_mlx_pci_pf

function mlx_configure() {
  echo "Configuring Mellanox for OKE"
  systemctl enable --now --no-block oci-cn-auth
  systemctl enable --now --no-block oci-hpc-mlx-configure
  oci-rdma-configure
  ibdev2netdev -v

  # Start Mellanox Software Tools service
  (mst status | grep "MST PCI configuration module loaded") || mst start

  # For each physical PCI device, configure the VFs
  get_mlx_pci_pf | while read -r pf; do
    echo "Configuring PF: $${pf}"
    enable_sriov "$${pf}" || echo "Error enabling SRIOV"
    configure_vfs "$${pf}" || echo "Error configuring VFs"
  done
}

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

  if [[ $(lspci || true | grep ".*Mellanox.*ConnectX") ]]; then
    time mlx_configure || echo "Error configuring Mellanox"
    if [[ -f "$${REBOOT_TRIGGER_FILE}" ]]; then
      rm -f "$${REBOOT_TRIGGER_FILE}"; echo "Rebooting"
      nohup bash -c "sleep 5 && reboot" &
      exit 0
    fi
  fi

  time oke_init
  time expand_filesystem || echo "Error expanding filesystem"
}

main "$@"
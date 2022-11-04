#!/usr/bin/env bash
# Copyright 2022, Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

set -e
source /etc/oke/oke-functions.sh

NUM_OF_VFS="$${NUM_OF_VFS:-2}" # Cluster Networks supports 2 VFs/PF

function interface_from_pci() {
  ibdev2netdev -v | grep "$${pci}" | grep -o "==> .* " | awk '{print $2}'
}

function numvfs_path_for_interface() {
  local interface="$${1}"
  echo "/sys/class/net/$${interface}/device/sriov_numvfs"
}

function available_num_vfs() {
  cat "$(numvfs_path_for_interface $${1})"
}

export -f interface_from_pci numvfs_path_for_interface available_num_vfs

function create_vfs() {
  set -x
  local pci="$${1}"
  local interface
  interface=$(interface_from_pci $${pci})
  available=$(available_num_vfs "$${interface}")
  numvfs_path=$(numvfs_path_for_interface "$${interface}")
  numvfs=$(cat "$${numvfs_path}" || echo "-1")

  if [[ ! -f "$${numvfs_path}" ]] || [[ "$${numvfs}" == "-1" ]]; then
    echo "Reboot required prior to VF creation"
    return
  fi

  if [[ "$${available}" != "$${NUM_OF_VFS}" ]]; then
    echo "Creating VFs for $${pci} (current: $${available}, target: $${NUM_OF_VFS})"
    echo "$${NUM_OF_VFS}" | tee "$${numvfs_path}" || echo "Error creating VFs for '$${pci}'"
    ibdev2netdev -v
  else
    echo "VFs already created"
  fi
  set +x
}

function get_mlx_pci_pf() {
  (lspci | grep ".*Mellanox.*ConnectX" | grep -v "Virtual" | awk '{print $1}') || true
}

function get_mlx_pci_vf() {
  (lspci | grep ".*Mellanox.*ConnectX" | grep "Virtual" | awk '{print $1}') || true
}


function main() {
  echo "Configuring Mellanox VFs for OKE"
  oci-rdma-configure || echo "Error configuring RDMA"
  ibdev2netdev -v || echo "Unable to list devices"

  # Start Mellanox Software Tools service
  mst status | grep "MST PCI configuration module loaded" || \
    (mst start || echo "Error starting MST service")

  # For each physical PCI device, configure the VFs
  get_mlx_pci_pf | while read -r pf; do
    echo "Configuring PF: $${pf}"
    create_vfs "$${pf}" || echo "Error creating VFs"
  done

  get_mlx_pci_vf | while read -r vf; do
    echo "VF present: $${vf}"
  done
}

if [[ $(lspci || true | grep ".*Mellanox.*ConnectX") ]]; then
  time main || echo "Error configuring Mellanox"
fi

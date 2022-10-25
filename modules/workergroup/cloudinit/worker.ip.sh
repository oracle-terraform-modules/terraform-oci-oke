#!/usr/bin/env bash
# Copyright 2022, Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Workaround: startup logging noise
sed -i 's/set -xe//g' /etc/oke/oke-functions.sh || echo "Error updating functions"

echo "Starting custom setup"
timedatectl set-timezone "${timezone}" || echo "Error updating timezone"

# Enable IMDS helper functions for login shell
echo 'source /etc/oke/oke-functions.sh || true' >> /etc/bash.bashrc
source /etc/oke/oke-functions.sh

# Write cluster DNS for Kubelet configuration
echo "${cluster_dns}" > /etc/oke/oke-cluster-dns
export CLUSTER_DNS="${cluster_dns}"
export APISERVER_ENDPOINT="${apiserver_host}"
export KUBELET_CA_CERT="${cluster_ca_cert}"

# Begin OKE worker node configuration
echo "Starting OKE install"
time bash /etc/oke/oke-install.sh \
  --apiserver-endpoint "${apiserver_host}" \
  --cluster-dns "${cluster_dns}" \
  --kubelet-ca-cert "${cluster_ca_cert}"
echo "Finished OKE install: $?"
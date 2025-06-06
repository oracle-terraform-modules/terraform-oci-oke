#!/usr/bin/env bash
# Copyright (c) 2022, 2025 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl
# shellcheck disable=SC1091 # Ignore unresolved file path present on base images
set -o pipefail

function get_imds_base_url() {
  imds_base_url=$(cat /tmp/imds_base_url || echo "")
  
  if [[ -z $imds_base_url ]]; then
    for url in "http://169.254.169.254/" "http://[fd00:c1::a9fe:a9fe]/"; do
      if curl -sSf -m 5 --retry 5 --retry-delay 1 -H 'Authorization: Bearer Oracle' -L0 "${url}opc/v2/instance/state" > /dev/null; then
        imds_base_url="$url"
        echo "$imds_base_url" > /tmp/imds_base_url
        break
      fi
    done
  fi
  
  if [ -z "${imds_base_url}" ]; then
    echo "Unable to determine imds base url" >&2
    exit 1
  fi
  
  echo "${imds_base_url}"
}

function curl_instance_metadata() {
  local imds_base="$(get_imds_base_url)"
  local url="${imds_base}$1"
  local retries=10
  local output
  
  while (( retries-- > 0 )); do
    if output=$(curl -sSf -m 5 -H 'Authorization: Bearer Oracle' -L0 "$url"); then
      echo "$output"
      return 0
    fi
    sleep 1
  done

  echo "Failed to fetch metadata from $url" >&2
  return 1
}

function get_imds_instance() {
  find "${INSTANCE_FILE}" -mmin -1 -not -empty > /dev/null 2>&1 || (curl_instance_metadata 'opc/v2/instance' | jq -rcM '.' > "${INSTANCE_FILE}")
  INSTANCE="$(cat "${INSTANCE_FILE}" || echo -n '')"
  
  export INSTANCE
  echo "${INSTANCE}"
}

function get_imds_metadata() {
  get_imds_instance | jq -rcM '.metadata // {}'
}

function run_oke_init() { # Initialize OKE worker node
  if [[ -f /etc/systemd/system/oke-init.service ]]; then
    systemctl --no-block enable --now oke-init.service
    return
  fi

  if [[ -f /etc/oke/oke-install.sh ]]; then
    local apiserver_host cluster_ca

    if [[ -f "/etc/oke/oke-apiserver" ]]; then
      apiserver_host=$(< /etc/oke/oke-apiserver)
    else
      apiserver_host=$(get_imds_metadata | jq -rcM '.apiserver_host')
    fi

    if [[ -f "/etc/kubernetes/ca.crt" ]]; then
      cluster_ca=$(base64 -w0 /etc/kubernetes/ca.crt)
    else
      cluster_ca=$(get_imds_metadata | jq -rcM '.cluster_ca_cert')
    fi

    bash /etc/oke/oke-install.sh \
      --apiserver-endpoint "${apiserver_host}" \
      --kubelet-ca-cert "${cluster_ca}"
    return
  fi
   
  local retries=5
  local delay=2
  local oke_init_relative_path="opc/v2/instance/metadata/oke_init_script"
  local script_path="/var/run/oke-init.sh"

  for (( i=0; i<retries; i++ )); do
    for url in "http://169.254.169.254/" "http://[fd00:c1::a9fe:a9fe]/"; do
      echo "Attempting to fetch OKE init script from ${base_url}${oke_init_relative_path}"
      if curl -sSf -H 'Authorization: Bearer Oracle' -L0 "${url}${oke_init_relative_path}" | base64 --decode > "${script_path}"; then
        bash "${script_path}"
        exit 0
      fi
    done
    echo "Retry $((i+1)) failed, retrying in $delay seconds..."
  done
}

INSTANCE_FILE="/etc/oke/imds_instance.json"
time run_oke_init || { echo "Error in OKE startup" >&2; exit 1; }
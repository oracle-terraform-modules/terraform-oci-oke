#!/usr/bin/env bash
# Copyright (c) 2017, 2022 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl
set -ae; CWD="$(dirname "$(readlink -f "$0")")"
function log() ( set +x; echo "${1}" >&2; )
function fatal() { log "FATAL: ${1}"; exit 1; }

DEBUG="${DEBUG:-false}"
if [[ "${DEBUG}" == 'true' ]]; then set -x; fi

# Input variables
source "${CWD}"/calico_env.sh || log 'No environment configuration found'
ACTION="${ACTION:-apply}"
DRY_RUN="${DRY_RUN:-none}"
CNI_TYPE="${CNI_TYPE:-flannel}"
MODE="${MODE:-policy}"
MTU="${MTU:-0}"
VERSION=${VERSION:-3.24.5}
URL="${URL:-}"
APISERVER_ENABLED="${APISERVER_ENABLED:-false}"
TYPHA_ENABLED="${TYPHA_ENABLED:-false}"
TYPHA_REPLICAS="${TYPHA_REPLICAS:-1}"
NUMBER_OF_NODES="${NUMBER_OF_NODES:-1}"
BASE_DIR="${BASE_DIR:-$(mktemp -t -d terraform-oci-oke_calico-XXXXXX)}"
SKIP_CLEANUP="${SKIP_CLEANUP:-false}"
DELETE_CRDS="${DELETE_CRDS:-false}"
YAML_DIR="${CWD}"/calico
MANIFEST_DIR="${BASE_DIR}"/manifest
APPLY_DIR="${BASE_DIR}"/apply
CRD_DIR="${BASE_DIR}"/crd

# Constants
readonly TYPHA_REMOVAL_PATCH='{"op": "replace", "path": "/data/typha_service_name", "value": "none"}'
readonly CNI_REMOVAL_PATCH='{"op": "remove", "path": "/data/cni_network_config"}'
readonly DAEMONSET_NPN_INIT_PATCH='[{"op": "remove", "path": "/spec/template/spec/initContainers/0"}]'
readonly OS_IMAGE_PATH='{range .items[*]}{@.status.nodeInfo.osImage}{"\n"}{end}'

# Remove temporary directory on exit
trap 'if [ "${SKIP_CLEANUP}" = false ]; then (rm -rf -- ${BASE_DIR}); else log "Skipping cleanup of ${BASE_DIR}"; fi' EXIT

# Resolve inconsistent location and path convention between manifest versions
function manifest_url() {
  if [ -n "${URL}" ]; then echo "${URL}"; return; fi # Use provided url if defined
  local version="${1}" v major minor
  IFS='.' read -r -a v <<< "${VERSION//v/}"
  major="${v[0]}"; minor="${v[1]}"
  if [[ "${major}" == '3' && "${minor}" -le '21' ]]; then
    version="${major}.${minor}"
    echo "https://docs.projectcalico.org/v${version}/manifests"
  else
    echo "https://raw.githubusercontent.com/projectcalico/calico/v${version}/manifests"
  fi
}

# Return the associated manifest URL for the configured installation mode
function get_manifest() {
  local url; url=$(manifest_url "${VERSION}")
  case "${1}" in
    canal)
      echo "${url}/canal.yaml";;
    vxlan)
      echo "${url}/calico-vxlan.yaml";;
    flannel-migration)
      echo "${url}/flannel-migration/{calico,migration-job}.yaml";;
    ipip)
      echo "${url}/calico.yaml";;
    apiserver)
      echo "${url}/apiserver.yaml";;
    *)
      echo "${url}/calico-policy-only.yaml";;
  esac
}

# Return the recommended MTU for the configured installation mode w/ IPv4
# https://projectcalico.docs.tigera.io/networking/mtu
function mtu_for_mode() {
  case ${1} in
    vxlan | canal | flannel-migration)
      echo 8950;;
    ipip)
      echo 8980;;
    *)
      echo 9000;;
  esac
}

function vxlan_for_mode() {
  case ${1} in
    vxlan | flannel-migration)
      echo "Always";;
    *)
      echo "Never";;
  esac
}

# Honor override from input parameter, or auto-detect
if [ "${MTU}" -eq 0 ]; then MTU=$(mtu_for_mode "${MODE}"); fi

# Return the configured installation mode if compatible with the cluster CNI
function mode_for_cni() {
  if [ "${CNI_TYPE}" = 'npn' ]; then
    echo 'policy' # Only policy is supported for VCN-Native CNI
  else
    echo "${MODE}"
  fi
}

# Determine podCIDR from Flannel ConfigMap
function get_pod_cidr() {
  kubectl get -n kube-system configmap kube-flannel-cfg \
    -o jsonpath="{.data['net-conf\.json']}" | grep -oP "\"Network\":\"\K([0-9./]*)"
}

# Update Daemonset environment variables for Flannel
function configure_daemonset_flannel() {
  IPV4POOL_VXLAN=$(vxlan_for_mode "${MODE}"); export IPV4POOL_VXLAN
  daemonset_flannel_env_patch=$(envsubst < "${YAML_DIR}"/calico-node-env-flannel.yaml)
  echo "${1}" | kubectl patch --dry-run='client' \
    --type='strategic' -f - --patch="${daemonset_flannel_env_patch}" -o yaml
}

# Update calico-config ConfigMap for Flannel
function configure_configmap_flannel() {
  # Add templated Felix configuration custom resource
  envsubst < "${YAML_DIR}"/felix-config-flannel.yaml > "${APPLY_DIR}"/felix-config.yaml

  # Update MTU
  output=$(echo "${1}" | kubectl patch --dry-run='client' --type='merge' \
    -f - --patch="{\"data\":{\"veth_mtu\": \"${MTU}\"}}" -o yaml)

  # Conditionally remove Typha service config
  if [[ ${INSTALL_TYPHA} = false ]]; then
    output=$(echo "${output}" | kubectl patch --dry-run='client' --type='json' \
      -f - --patch="[${TYPHA_REMOVAL_PATCH}]" -o yaml)
  fi

  echo "${output}"
}

# Update Daemonset environment variables for VCN-Native Pod Networking
function configure_daemonset_native() {
  IPV4POOL_VXLAN=$(vxlan_for_mode "${MODE}"); export IPV4POOL_VXLAN
  daemonset_npn_env_patch=$(envsubst < "${YAML_DIR}"/calico-node-env-npn.yaml)
  output=$(echo "${1}" | kubectl patch --dry-run='client' \
    -f - --type='strategic' --patch="${daemonset_npn_env_patch}" -o yaml)

  # Remove calico-node Daemonset install-cni initContainer
  echo "${output}" | kubectl patch --dry-run='client' \
    -f - --type='json' --patch="${DAEMONSET_NPN_INIT_PATCH}" -o yaml
}

# Update calico-config ConfigMap for VCN-Native Pod Networking
function configure_configmap_native() {
  # Add templated Felix configuration custom resource
  envsubst < "${YAML_DIR}"/felix-config-npn.yaml > "${APPLY_DIR}"/felix-config.yaml

  # Remove unused CNI netconf
  config_patch="${CNI_REMOVAL_PATCH}"

  # Conditionally remove Typha service config
  if [[ ${INSTALL_TYPHA} = false ]]; then
    config_patch="${config_patch},${TYPHA_REMOVAL_PATCH}"
  fi

  echo "${1}" | kubectl patch --dry-run='client' --type='json' \
    -f - --patch="[${config_patch}]" -o yaml
}

# Update Typha Deployment configuration
function configure_typha() {
  TYPHA_REPLICAS_PATCH="[{\"op\": \"replace\", \"path\": \"/spec/replicas\", \"value\": ${TYPHA_REPLICAS}}]"
  echo "${1}" | kubectl patch --dry-run='client' \
    -f - --type='json' --patch="${TYPHA_REPLICAS_PATCH}" -o yaml
}

# Determine latest OS release (e.g. Oracle Linux 7.x/8.x) for nodes
function get_os_image() {
  kubectl get nodes -o jsonpath="${OS_IMAGE_PATH}" \
  | sort -ur | head -1
}

# Return the name of the Daemonset for the configured mode
function daemonset_for_mode() {
  if [ "${1}" = 'canal' ]; then
    echo 'canal'
  else
    echo 'calico-node'
  fi
}

# Return the name of the ConfigMap for the configured mode
function configmap_for_mode() {
  if [ "${1}" = 'canal' ]; then
    echo 'canal-config'
  else
    echo 'calico-config'
  fi
}

# Initialize manifest/YAML directories
log "Working directory: ${CWD}"
log "Manifest directory: ${MANIFEST_DIR}"
log "CRD directory: ${CRD_DIR}"
log "Apply directory: ${APPLY_DIR}"
rm -rf "${MANIFEST_DIR}" "${APPLY_DIR}" "${CRD_DIR}"
mkdir -p "${MANIFEST_DIR}" "${APPLY_DIR}" "${CRD_DIR}"

# Download Calico YAML manifest for configured MODE
MODE=$(mode_for_cni)
MANIFEST_URL=$(get_manifest "${MODE}")
log "Preparing ""${ACTION}"" for Calico v${VERSION} in ${MODE} MODE on ${CNI_TYPE} (dry_run: '${DRY_RUN}')"
log "Downloading from ${MANIFEST_URL}"
curl --fail -s -L "${MANIFEST_URL}" -o "${MANIFEST_DIR}"/manifest-#1.yaml || (fatal 'Error downloading YAML')

# Split resources into separate yaml files
awk -v output_directory="${APPLY_DIR}" -f "${CWD}"/split_yaml.awk "${MANIFEST_DIR}"/manifest-*.yaml

# Move CRDs to separate directory
mv "${APPLY_DIR}"/*.customresourcedefinition.yaml "${CRD_DIR}"/

# Create CRDs first
if [ "${ACTION}" = 'apply' ]; then
  kubectl "${ACTION}" --dry-run="${DRY_RUN}" -R -f "${CRD_DIR}"
fi

INSTALL_TYPHA=false
if [ "${CNI_TYPE}" = 'flannel' ] && [[ ${TYPHA_ENABLED} = true || ${NUMBER_OF_NODES} -gt 50 ]] && \
   [[ -f "${APPLY_DIR}/calico-typha.deployment.yaml" ]]; then
  INSTALL_TYPHA=true
fi

# Determine appropriate IPTables backend for OS release
if [[ "$(get_os_image)" =~ ([8-9]\.) ]]; then
  export IPTABLES_BACKEND='NFT'
else
  export IPTABLES_BACKEND='Legacy'
fi

# Read daemonset/configmap resources for modifcation
DAEMONSET="$(daemonset_for_mode "${MODE}")"
DAEMONSET_FILE="${APPLY_DIR}/${DAEMONSET}.daemonset.yaml"
CONFIGMAP_FILE="${APPLY_DIR}/$(configmap_for_mode "${MODE}").configmap.yaml"
DAEMONSET_INPUT=$(cat "${DAEMONSET_FILE}")
CONFIGMAP_INPUT=$(cat "${CONFIGMAP_FILE}")
IPV4POOL_VXLAN=$(vxlan_for_mode "${MODE}")

# Update resources in accordance with configured cluster CNI
if [ "${CNI_TYPE}" = 'npn' ]; then
  DAEMONSET_OUTPUT=$(configure_daemonset_native "${DAEMONSET_INPUT}")
  CONFIGMAP_OUTPUT=$(configure_configmap_native "${CONFIGMAP_INPUT}")
elif [ "${CNI_TYPE}" = 'flannel' ]; then
  DAEMONSET_OUTPUT=$(configure_daemonset_flannel "${DAEMONSET_INPUT}")
  CONFIGMAP_OUTPUT=$(configure_configmap_flannel "${CONFIGMAP_INPUT}")
else
  fatal "Unrecognized cni_type: ${CNI_TYPE}"
fi

# Write modified resources to filesystem to be applied
rm -f "${CONFIGMAP_FILE}" "${DAEMONSET_FILE}"
echo "${DAEMONSET_OUTPUT}" > "${DAEMONSET_FILE}"
echo "${CONFIGMAP_OUTPUT}" > "${CONFIGMAP_FILE}"

# Conditionally prepare Typha resources on Flannel only (not respecting interfacePrefix for NPN)
if [ ${INSTALL_TYPHA} = true ]; then
  log "Enabling Typha for ${NUMBER_OF_NODES} node(s) with ${TYPHA_REPLICAS} replica(s) (forced: ${TYPHA_ENABLED})"
  typha_input=$(cat "${APPLY_DIR}"/calico-typha.deployment.yaml)
  typha_output=$(configure_typha "${typha_input}")
  rm -f "${APPLY_DIR}"/calico-typha.deployment.yaml
  echo "${typha_output}" > "${APPLY_DIR}"/calico-typha.deployment.yaml
else
  log "Typha is disabled (${NUMBER_OF_NODES} node(s); forced: ${TYPHA_ENABLED})"
  rm -f "${APPLY_DIR}"/calico-typha.*.yaml
fi

# Install config/rbac first
if [ "${ACTION}" = 'apply' ]; then
  for file in \
    "${APPLY_DIR}"/*.serviceaccount.yaml \
    "${APPLY_DIR}"/*.clusterrole*.yaml \
    "${APPLY_DIR}"/*.configmap.yaml \
    "${APPLY_DIR}"/felix-config.yaml; do
      kubectl "${ACTION}" --dry-run="${DRY_RUN}" -f "${file}" && rm -f "${file}"
  done
fi

# Install and wait for Typha, if enabled on Flannel only (not respecting interfacePrefix for NPN)
if [ ${INSTALL_TYPHA} = true ]; then
  for file in \
    "${APPLY_DIR}"/calico-typha.*.yaml; do
      kubectl "${ACTION}" --dry-run="${DRY_RUN}" -f "${file}" && rm -f "${file}"
  done
  if [ "${DRY_RUN}" = 'none' ]; then
    kubectl -n kube-system rollout status deployment/calico-typha -w
  fi
fi

# Install daemonset + related
for file in \
  "${APPLY_DIR}"/"${DAEMONSET}".*.yaml; do
    kubectl "${ACTION}" --dry-run="${DRY_RUN}" -f "${file}" && rm -f "${file}"
done

# Wait for daemonset to become ready
if [ "${ACTION}" = 'apply' ] && [ "${DRY_RUN}" = 'none' ]; then
  kubectl -n kube-system rollout status daemonset/"${DAEMONSET}" -w
fi

# Perform action on remaining resources
kubectl "${ACTION}" --dry-run="${DRY_RUN}" -R -f "${APPLY_DIR}"

# Delete CRDs last, if enabled
if [ "${ACTION}" = 'delete' ] && [ "${DELETE_CRDS}" = true ]; then
  kubectl "${ACTION}" --dry-run="${DRY_RUN}" -R -f "${CRD_DIR}"
fi

# Restart system deployments to be Calico-CNI-managed (skipped for VCN-Native Pod Networking)
if [ "${CNI_TYPE}" = 'flannel' ] && [ "${ACTION}" = 'apply' ] && [ "${DRY_RUN}" = 'none' ]; then
  for resource in 'deployment/coredns' 'deployment/kube-dns-autoscaler'; do
    kubectl -n kube-system rollout restart "${resource}"
    kubectl -n kube-system rollout status "${resource}" -w
  done
fi

# Conditionally prepare Calico apiserver resources
if [[ ${APISERVER_ENABLED} = true ]]; then
  apiserver_url=$(get_manifest apiserver)
  log "Calico apiserver enabled; downloading from ${apiserver_url}"
  curl --fail -s -L "${apiserver_url}" -o "${MANIFEST_DIR}"/apiserver.yaml || \
    (fatal 'Error downloading Calico apiserver YAML')
  kubectl "${ACTION}" --dry-run="${DRY_RUN}" -f "${MANIFEST_DIR}"/apiserver.yaml
  if [ "${ACTION}" = 'apply' ]; then
    log 'Generating Calico apiserver certificate'
    openssl req -x509 -nodes -newkey rsa:4096 \
      -keyout "${MANIFEST_DIR}"/apiserver.key -out "${MANIFEST_DIR}"/apiserver.crt \
      -days 365 -subj "/" -addext "subjectAltName = DNS:calico-api.calico-apiserver.svc"
    if [ "${DRY_RUN}" = 'none' ]; then
      kubectl -n calico-apiserver create --dry-run='client' secret generic calico-apiserver-certs \
        --from-file="${MANIFEST_DIR}"/apiserver.key --from-file="${MANIFEST_DIR}"/apiserver.crt \
        -o yaml | kubectl "${ACTION}" -f -
      caBundle="$(kubectl get secret -n calico-apiserver calico-apiserver-certs -o go-template='{{ index .data "apiserver.crt" }}')"
      kubectl patch apiservice v3.projectcalico.org -p "{\"spec\": {\"caBundle\": \"${caBundle}\"}}"
      kubectl -n calico-apiserver rollout status deployment/calico-apiserver -w
    fi
  fi
fi

log "Finished Calico ${MODE} ${ACTION}"

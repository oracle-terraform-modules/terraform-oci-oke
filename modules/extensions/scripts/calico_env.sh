#!/usr/bin/env bash
# Copyright (c) 2022 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl
# shellcheck disable=SC2034,SC2154,SC2269 # Ignore templated file variables
set -ae
MODE=${mode}
VERSION=${version}
CNI_TYPE=${cni_type}
POD_CIDR=${pod_cidr}
MTU=${mtu}
URL=${url}
APISERVER_ENABLED=${apiserver_enabled}
TYPHA_ENABLED=${typha_enabled}
TYPHA_REPLICAS=${typha_replicas}
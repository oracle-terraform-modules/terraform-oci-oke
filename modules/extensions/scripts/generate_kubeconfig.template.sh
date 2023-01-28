#!/usr/bin/env bash
# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl
# shellcheck disable=SC2034,SC2086,SC2154,SC2269 # Ignore templated file variables

oci ce cluster create-kubeconfig \
  --region ${region} \
  --cluster-id ${cluster-id} \
  --file ~/.kube/config  \
  --token-version 2.0.0 \
  --auth instance_principal \
  --kube-endpoint PRIVATE_ENDPOINT

chmod go-r ~/.kube/config
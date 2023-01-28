#!/usr/bin/env bash
# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl
# shellcheck disable=SC2034,SC2086,SC2154,SC2269 # Ignore templated file variables

kubectl config set-credentials "user-${cluster-id-11}" --exec-command="$HOME/bin/token_helper.sh" \
  --exec-arg="ce" \
  --exec-arg="cluster" \
  --exec-arg="generate-token" \
  --exec-arg="--cluster-id" \
  --exec-arg="${cluster-id}" \
  --exec-arg="--region" \
  --exec-arg="${region}"

kubectx default="$(kubectl config current-context)"
#!/bin/bash
# Copyright 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

kubectl config set-credentials "user-${cluster-id-11}" --exec-command="./token_helper.sh" \
  --exec-arg="ce" \
  --exec-arg="cluster" \
  --exec-arg="generate-token" \
  --exec-arg="--cluster-id" \
  --exec-arg="${cluster-id}" \
  --exec-arg="--region" \
  --exec-arg="${region}"
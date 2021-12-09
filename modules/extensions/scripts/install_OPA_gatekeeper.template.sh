#!/bin/bash
# Copyright 2017, 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

if [ ! -f .OPA_completed ]; then

  echo "Installing OPA Gatekeeper"
  kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/release-${OPA_gatekeeper_version}/deploy/gatekeeper.yaml > /dev/null 2>&1

  touch .OPA_completed
fi
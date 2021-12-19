#!/bin/bash
# Copyright 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

if [ ! -f .gatekeeper_completed ]; then

  echo "Installing Open Policy Agent Gatekeeper"
  kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/release-${gatekeeeper_version}/deploy/gatekeeper.yaml > /dev/null 2>&1

  touch .gatekeeper_completed
fi
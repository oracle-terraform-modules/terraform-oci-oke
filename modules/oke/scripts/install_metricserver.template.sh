#!/bin/bash
# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

if [ ! -f .metrics_completed ]; then

  echo "Installing Metrics Server"
  kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml > /dev/null 2>&1

  sleep 5

  if [ ${vpa_enabled} = true ]; then
    echo "Installing Vertical Pod Autoscaler"
    cd /tmp > /dev/null 2>&1
    git clone -b vpa-release-${vpa_version} https://github.com/kubernetes/autoscaler.git > /dev/null 2>&1
    cd /tmp/autoscaler/vertical-pod-autoscaler > /dev/null 2>&1
    ./hack/vpa-down.sh > /dev/null 2>&1
    ./hack/vpa-up.sh > /dev/null 2>&1
    cd && rm -rf /tmp/autoscaler > /dev/null 2>&1
  fi
  touch .metrics_completed
fi
#!/bin/bash
# Copyright 2017, 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

echo "Installing Verrazzano Enterprise Container Platform"

kubectl apply -f https://github.com/verrazzano/verrazzano/releases/download/v${verrazzano_version}/operator.yaml

kubectl -n verrazzano-install rollout status deployment/verrazzano-platform-operator


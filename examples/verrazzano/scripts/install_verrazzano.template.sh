#!/bin/bash
# Copyright 2017, 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

echo "Installing Verrazzano"

cat << EOF > v8o-dev.yaml
apiVersion: install.verrazzano.io/v1alpha1
kind: Verrazzano
metadata:
  name: example-verrazzano
spec:
  profile: dev
EOF

sed -i -e "s?example-verrazzano?${verrazzano_name}?g" v8o-dev.yaml

kubectl apply -f v8o-dev.yaml
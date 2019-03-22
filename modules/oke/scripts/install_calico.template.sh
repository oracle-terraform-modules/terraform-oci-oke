#!/bin/bash
# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

mkdir calico

cd calico

kubectl create clusterrolebinding clusteradminrole --clusterrole=cluster-admin --user=${user_ocid}

kubectl apply -f https://docs.projectcalico.org/v${calico_version}/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml

curl https://docs.projectcalico.org/v${calico_version}/getting-started/kubernetes/installation/hosted/kubernetes-datastore/policy-only/1.7/calico.yaml -O

sleep 10

if [ '${number_of_nodes}' > 50 ]; then
  echo "More than 50 nodes detected. Setting the typha service name"
  sed -i -e 's/typha_service_name:\s"none"/typha_service_name: calico-typha/g' calico.yaml
fi

kubectl apply -f calico.yaml

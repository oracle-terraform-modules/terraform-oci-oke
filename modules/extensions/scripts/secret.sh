#!/bin/bash
# Copyright 2017, 2020, Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

if [ ${secret_namespace} != default ]; then
  cat <<EOF | kubectl apply -f -
  apiVersion: v1
  kind: Namespace
  metadata:
    name: ${secret_namespace}
EOF
fi

crtsecret=$(kubectl create secret docker-registry ${secret_name} -n ${secret_namespace} --docker-server=${region_registry} --docker-username=${tenancy_namespace}/${username} --docker-email=${email_address} --docker-password=`oci secrets secret-bundle get --raw-output --secret-id ${secret_id} --query "data.\"secret-bundle-content\".content" | base64 -d` --dry-run=client -o yaml | kubectl apply -f -)
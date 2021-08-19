#!/bin/bash
# Copyright 2017, 2020, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
    name: ${secret_ns}
EOF


crtsecret=$(kubectl create secret docker-registry ${secret_name} -n ${secret_ns} --docker-server=${region_registry} --docker-username=${tenancy_namespace}/${username} --docker-email=${email_address} --docker-password=`oci secrets secret-bundle get --raw-output --secret-id ${secret_id} --query "data.\"secret-bundle-content\".content" | base64 -d` --dry-run=client -o yaml | kubectl apply -f -)
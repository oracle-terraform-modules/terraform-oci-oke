#!/bin/bash
# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

if [ ${tiller_enabled} ]; then
  kubectl -n kube-system delete secret ocirsecret
  kubectl create secret docker-registry ocirsecret -n kube-system --docker-server=${region_registry} --docker-username=${tenancy_name}/${username} --docker-email=${email_address} --docker-password='${authtoken}'
  kubectl -n kube-system patch serviceaccount tiller -p '{"imagePullSecrets": [{"name": "ocirsecret"}]}'
else
  kubectl -n default delete secret ocirsecret
  kubectl create secret docker-registry ocirsecret -n default --docker-server=${region_registry} --docker-username=${tenancy_name}/${username} --docker-email=${email_address} --docker-password='${authtoken}'
fi  
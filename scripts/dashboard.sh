#!/bin/bash
#  Copyright 2017, 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

export KUBECONFIG=generated/kubeconfig

echo 'Access K8s Dashboard: http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/'

echo 'Login with the kubeconfig in generated/kubeconfig file'

kubectl proxy

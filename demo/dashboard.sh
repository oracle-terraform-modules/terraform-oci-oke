#!/bin/bash
#  Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

export KUBECONFIG=generated/kubeconfig

echo 'Access K8s Dashboard: http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/'

echo 'Login with the kubeconfig in generated/kubeconfig file'

kubectl proxy

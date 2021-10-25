#!/bin/bash
# Copyright 2017, 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

if [ ! -f .sa_completed ]; then
  if [ ${service_account_namespace} != kube-system ]; then
    kubectl create ns ${service_account_namespace}
  fi

  kubectl -n ${service_account_namespace} create serviceaccount ${service_account_name}

  kubectl create clusterrolebinding ${service_account_cluster_role_binding} --clusterrole=cluster-admin --serviceaccount=${service_account_namespace}:${service_account_name}
  touch .sa_completed
fi 
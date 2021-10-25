#!/bin/bash
# Copyright 2017, 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

if [ ! -f $HOME/.kube/config ]; then
  oci ce cluster create-kubeconfig --cluster-id ${cluster-id} --file $HOME/.kube/config  --region ${region} --token-version 2.0.0 --auth instance_principal --kube-endpoint PRIVATE_ENDPOINT

  chmod go-r $HOME/.kube/config
fi
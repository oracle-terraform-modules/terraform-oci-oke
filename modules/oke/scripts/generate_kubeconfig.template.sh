#!/bin/bash
# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl


while [ ! -f /home/opc/admin.finish ]  || [ ! -f /home/opc/ip.finish  ];
do
  echo "waiting for admin to be ready"; sleep 10;
done

sleep 30

oci ce cluster create-kubeconfig --cluster-id ${cluster-id} --file $HOME/.kube/config  --region ${region} --token-version 2.0.0
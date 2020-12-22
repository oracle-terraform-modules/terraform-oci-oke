#!/bin/bash
# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

echo "Installing calico for network policy"

mkdir calico && cd calico > /dev/null 2>&1

curl https://docs.projectcalico.org/manifests/canal.yaml -O > /dev/null 2>&1

kubectl apply -f canal.yaml > /dev/null 2>&1

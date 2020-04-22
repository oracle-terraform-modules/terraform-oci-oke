#!/bin/bash
# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

git clone https://github.com/kubernetes-sigs/metrics-server.git /tmp/metricserver
cd /tmp/metricserver
kubectl create -f manifests/

sleep 5
rm -rf /tmp/metricserver/

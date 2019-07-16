#!/bin/bash
# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

git clone https://github.com/kubernetes-incubator/metrics-server.git /tmp/metricserver
cd /tmp/metricserver
kubectl create -f deploy/${kubernetes_version_metricserver}+/

sleep 5
rm -rf /tmp/metricserver/

#!/bin/bash
# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

wget https://storage.googleapis.com/kubernetes-helm/helm-v${helm_version}-linux-amd64.tar.gz

tar zxvf helm-v${helm_version}-linux-amd64.tar.gz

sudo mv linux-amd64/helm /usr/local/bin

rm -rf linux-amd64

helm init --upgrade

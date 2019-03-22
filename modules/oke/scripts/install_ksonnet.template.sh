#!/bin/bash
# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

wget https://github.com/ksonnet/ksonnet/releases/download/v${ksonnet_version}/ks_${ksonnet_version}_linux_amd64.tar.gz

tar zxvf ks_${ksonnet_version}_linux_amd64.tar.gz

sudo mv ks_${ksonnet_version}_linux_amd64/ks /usr/local/bin

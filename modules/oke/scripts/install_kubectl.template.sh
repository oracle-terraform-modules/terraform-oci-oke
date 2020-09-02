#!/bin/bash
# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

sleep 60s

sudo yum install -y oracle-olcne-release-el7

sudo yum-config-manager --enable ol7_olcne11

sudo yum install -y kubectl git

mkdir ~/.kube

echo "source <(kubectl completion bash)" >> ~/.bashrc
echo "alias k='kubectl'" >> ~/.bashrc
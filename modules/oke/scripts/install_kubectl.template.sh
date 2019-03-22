#!/bin/bash
# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

if [ '${package_manager}' = "yum" ]; then
  sudo yum install -y kubectl git
else
  sudo apt install -y git 
  sudo snap install kubectl --classic
fi

mkdir ~/.kube

echo "source <(kubectl completion bash)" >> ~/.bashrc

#!/bin/bash
# Copyright 2017, 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

if [ ! -f .helm_completed ]; then
  sudo yum install -y helm

  echo "source <(helm completion bash)" >> ~/.bashrc
  echo "alias h='helm'" >> ~/.bashrc
  echo "helm completed"
  touch .helm_completed
fi
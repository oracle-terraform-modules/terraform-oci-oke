#!/bin/bash
# Copyright 2017, 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

if [ ! -f .kubectl_completed ]; then
  while [ ! -f /home/opc/operator.finish ]; 
    do echo "waiting for operator. sleeping for 10s"; sleep 10; 
  done

  if [ ${ol} = 8 ]; then
    sudo dnf -q install -y oracle-olcne-release-el8

    sudo dnf -q config-manager --enable ol8_olcne15

    sudo dnf -q install -y kubectl git
  else 
    sudo yum -q install -y oracle-olcne-release-el7

    sudo yum-config-manager --enable ol7_olcne15

    sudo yum -q install -y kubectl git
  fi

  mkdir ~/.kube

  echo "source <(kubectl completion bash)" >> ~/.bashrc
  echo "alias k='kubectl'" >> ~/.bashrc

  echo "kubectl completed"

  touch .kubectl_completed
fi
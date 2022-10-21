#!/bin/bash
# Copyright 2022 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

curl -sSfL https://github.com/ahmetb/kubectx/releases/download/v${version}/kubectx_v${version}_linux_$(uname -m).tar.gz | sudo tar zxvf - -C /usr/local --xform='s|^|kubectx/|S'
curl -sSfL https://github.com/ahmetb/kubectx/releases/download/v${version}/kubens_v${version}_linux_$(uname -m).tar.gz | sudo tar zxvf - -C /usr/local --xform='s|^|kubens/|S'

sudo ln -s /usr/local/kubectx/kubectx /usr/bin/kubectx 
sudo ln -s /usr/local/kubens/kubens /usr/bin/kubens

echo "source <(kubectl completion bash)" >> ~/.bashrc
echo "alias k='kubectl'" >> $HOME/.bashrc

echo "source <(helm completion bash)" >> ~/.bashrc
echo "alias h='helm'" >> ~/.bashrc

echo "alias ktx='kubectx'" >> $HOME/.bashrc
echo "alias kns='kubens'" >> $HOME/.bashrc
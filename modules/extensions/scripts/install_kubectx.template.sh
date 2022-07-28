#!/bin/bash
# Copyright 2022 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

curl -sSfL https://github.com/ahmetb/kubectx/releases/download/v0.9.4/kubectx_v0.9.4_linux_x86_64.tar.gz -o kubectx_v0.9.4_linux_x86_64.tar.gz
curl -sSfL https://github.com/ahmetb/kubectx/releases/download/v0.9.4/kubens_v0.9.4_linux_x86_64.tar.gz -o kubens_v0.9.4_linux_x86_64.tar.gz

tar zxf  kubectx_v0.9.4_linux_x86_64.tar.gz
tar zxf kubens_v0.9.4_linux_x86_64.tar.gz
rm -f  kubectx_v0.9.4_linux_x86_64.tar.gz
rm -f kubens_v0.9.4_linux_x86_64.tar.gz
rm -f LICENSE

sudo mv kubectx /usr/local/bin
sudo mv kubens /usr/local/bin

echo "alias ktx='kubectx'" >> $HOME/.bashrc
echo "alias kns='kubens'" >> $HOME/.bashrc
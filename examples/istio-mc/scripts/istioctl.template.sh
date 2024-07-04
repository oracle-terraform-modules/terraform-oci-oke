#!/usr/bin/bash
# Copyright (c) 2024 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

echo "Installing istioctl"
curl -L curl -L https://istio.io/downloadIstio | ISTIO_VERSION=${version} TARGET_ARCH=x86_64 sh -
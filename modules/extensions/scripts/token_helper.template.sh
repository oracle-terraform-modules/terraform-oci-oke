#!/bin/bash
# Copyright 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

TOKEN_FILE=~/.kube/TOKEN

if ! test -f "$TOKEN_FILE" || test $(( `date +%s` - `stat -L -c %Y $TOKEN_FILE` )) -gt 240; then
  umask 022
  oci ce cluster generate-token --cluster-id ${cluster-id} --region ${region} >$TOKEN_FILE
fi

cat $TOKEN_FILE
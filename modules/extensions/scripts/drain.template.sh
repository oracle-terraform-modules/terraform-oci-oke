#!/usr/bin/env bash
# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# TODO Re-implement
for node in $(cat drainlist.txt)
do 
  kubectl drain $node --force --ignore-daemonsets
  echo $node drained
done
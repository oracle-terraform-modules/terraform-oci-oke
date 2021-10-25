#!/bin/bash
# Copyright 2017, 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

rm -f all_node.active
rm -f one_node.active

while [ ! -f $HOME/*node.active ]
do
  echo 'sleeping for 30s'
  sleep 30
  if [ ${check_node_active} == all ]; then
    echo 'checking if all worker nodes are active'
    active_workers=`(kubectl get nodes | awk 'NR>1 {print $2}' | wc -l)`
    echo $active_workers 'active worker nodes found out of ${total_nodes}'
    if [ $active_workers -eq ${total_nodes} ]; then
      touch all_node.active
    fi
  else
    echo 'checking if 1 active worker node'
    active_workers=`(kubectl get nodes | awk 'NR>1 {print $2}' | wc -l)`
    if [ $active_workers -ge 1 ]; then
      echo '1 active worker node found'
      touch one_node.active
    fi
  fi
done
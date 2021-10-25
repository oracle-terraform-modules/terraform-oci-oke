#!/usr/bin/python3
# Copyright 2017, 2020, Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl
# Derived and adapted from https://www.ateam-oracle.com/secure-way-of-managing-secrets-in-oci

import os
import oci
from oci.container_engine import ContainerEngineClient

compartment_id = '${compartment_id}'
cluster_id = '${cluster_id}'
region = '${region}'
pools_to_drain = ['${pools_to_drain}']

signer = oci.auth.signers.InstancePrincipalsSecurityTokenSigner()

identity_client = oci.identity.IdentityClient(config={}, signer=signer)

oce = oci.container_engine.ContainerEngineClient(config={'region': region}, signer=signer)

# Get list of node pools
list_pools = []

for p in pools_to_drain:
    list_pools = oce.list_node_pools(compartment_id,cluster_id=cluster_id,name=p)

# Count number of node pools to upgrade
    number_of_node_pools = len(list_pools.data)

# Get list of node pool ids to upgrade
    pool_ids = []

    for n in range(0,number_of_node_pools):
        pool_ids.append(list_pools.data[n].id)

# for all node pool ids to upgrade, get a list of node pools
    node_pools = []

    for node_pool_id in pool_ids:
        resp = oce.get_node_pool(node_pool_id)
        node_pools.append(resp.data)

# for all node pools to upgrade, get a list of their worker nodes
    all_nodes = []

    for nodepool in node_pools:
        try:
            nodes = nodepool.nodes
            for node in nodes:
                all_nodes.append(node)
        except TypeError:
            continue

# for each node in the node pool, get their private_ip and write to file
    with open('drainlist.txt', 'a') as filehandle:
      for nodepool in node_pools:
          try:
              nodes = nodepool.nodes
              for node in nodes:
                  filehandle.write('%s\n' % node.private_ip)
          except TypeError:
              continue
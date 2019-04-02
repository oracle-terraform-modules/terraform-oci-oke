#!/bin/python
# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

import os
import oci
from oci.container_engine import ContainerEngineClient

compartment_id = '${compartment_id}'
cluster_id = '${cluster_id}'
region = '${region}'

signer = oci.auth.signers.InstancePrincipalsSecurityTokenSigner()

identity_client = oci.identity.IdentityClient(config={}, signer=signer)

oce = oci.container_engine.ContainerEngineClient(config={'region': region}, signer=signer)

# Get list of node pools
list_pools = []

list_pools = oce.list_node_pools(compartment_id,cluster_id=cluster_id)

# Count number of node pools
number_of_node_pools = len(list_pools.data)

# Get list of node pool ids
pool_ids = []

for n in range(0,number_of_node_pools):
    pool_ids.append(list_pools.data[n].id)
    
# for all node pool ids, get a list of node pool
node_pools = []

for node_pool_id in pool_ids:
    resp = oce.get_node_pool(node_pool_id)
    node_pools.append(resp.data)

# for all node pools, get a list of nodes
all_nodes = []    

for nodepool in node_pools:
    try:
        nodes = nodepool.nodes
        for node in nodes:
            all_nodes.append(node)
    except TypeError:
        continue

# for each node in the node pool, get the lifecycle_state
all_statuses = []

for nodepool in node_pools:
    try:
        nodes = nodepool.nodes
        for node in nodes:
            all_statuses.append(node.lifecycle_state)
    except TypeError:
        continue
        
# if there's a worker node that is active, create a file node.active
if "ACTIVE" in all_statuses:
    os.mknod("node.active")

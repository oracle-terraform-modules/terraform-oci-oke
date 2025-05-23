
# Workers: Node Cycle

Cycling nodes simplifies both the upgrading of the Kubernetes and host OS versions running on the managed worker nodes, and the updating of other worker node properties.

When you set `node_cycling_enabled` to `true` for a node pool, OKE will compare the properties of the existing nodes in the node pool with the properties of the node_pool. If any of the following attributes is not aligned, the node is marked for replacement:
  - `kubernetes_version`
  - `node_labels`
  - `compute_shape` (`shape`, `ocpus`, `memory`)
  - `boot_volume_size`
  - `image_id`
  - `node_metadata`
  - `ssh_public_key`
  - `cloud_init`
  - `nsg_ids`
  - `volume_kms_key_id`
  - `pv_transit_encryption`

The `node_cycling_max_surge` (default: `1`) and `node_cycling_max_unavailable` (default: `0`) node_pool attributes can be configured with absolute values or percentage values, calculated relative to the node_pool `size`. These attributes determine how OKE will replace the nodes with a stale config in the node_pool.

The `node_cycling_mode` attribute supports two node cycling modes:
- `instance` - (default) - cycling deletes and recreates a new node with the changes applied.
- `boot_volume` cycling swaps the boot volume on the same node.

**Notes:**
- Only a subset of fields (`kubernetes_version`, `image_id`, `boot_volume_size`, `node_metadata`, `ssh_public_key`, `volume_kms_key_id`) can be changed with `boot_volume` cycling.
- The cycling operation will attempt to bring all nodes in the NodePool in sync with the NodePool specification. If `boot_volume` cycling mode is chosen, and the node needs changes to fields that can not be updated via a `boot_volume` cycle, the cycle attempt for that node will fail. The cycle_mode has to be changed to `instance` and the node-cycle operation needs to be retried.

When cycling nodes, the OKE cordons, drains, and terminates nodes according to the node pool's cordon and drain options.

**Notes:**
- It's strongly recommended to use [readiness probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-readiness-probes) and [PodDisruptionBudgets](https://kubernetes.io/docs/tasks/run-application/configure-pdb/) to reduce the impact of the node replacement operation.
- This operation is supported only with the `enhanced` OKE clusters.
- New nodes will be created within the same AD/FD as the ones they replace.
- Node cycle requests can be canceled but can't be reverted.
- When setting a high `node_cycling_max_surge` value, check your [tenancy compute limits](https://docs.oracle.com/en-us/iaas/Content/General/Concepts/servicelimits.htm#computelimits) to confirm availability of resources for the new worker nodes.
- Compatible with the cluster_autoscaler. During node-cycling execution, the request to reduce node_pool size is rejected, and all the worker nodes within the cycled node_pool are annotated with `"cluster-autoscaler.kubernetes.io/scale-down-disabled": "true"` to prevent the termination of the newly created nodes.
- `node_cycling_enabled = true` is incompatible with changes to the node_pool `placement_config` (subnet_id, availability_domains, placement_fds, etc.)
- If the `kubernetes_version` attribute is changed when `image_type = custom`, ensure a compatible `image_id` with the new Kubernetes version is provided.


## Usage

```javascript
{{#include ../../../examples/workers/vars-workers-node-cycling.auto.tfvars:4:}}
```

## References
* [oci_containerengine_node_pool](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/containerengine_node_pool)
* [Performing an In-Place Worker Node Update by Cycling Nodes in an Existing Node Pool](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengupgradingimageworkernode_topic-Performing_an_InPlace_Worker_Node_Update_By_Cycling_an_Existing_Node_Pool.htm)
* [Introducing On Demand Node Cycling for OCI Kubernetes Engine](https://blogs.oracle.com/cloud-infrastructure/post/node-cycling-container-engine-kubernetes-oke)

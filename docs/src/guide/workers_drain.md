# Workers: Draining

## Usage

```javascript
{{#include ../../../examples/workers/vars-workers-drain.auto.tfvars:4:}}
```

## Example

```
Terraform will perform the following actions:

  # module.workers_only.module.utilities[0].null_resource.drain_workers[0] will be created
  + resource "null_resource" "drain_workers" {
      + id       = (known after apply)
      + triggers = {
          + "drain_commands" = jsonencode(
                [
                  + "kubectl drain --timeout=900s --ignore-daemonsets=true --delete-emptydir-data=true -l oke.oraclecloud.com/pool.name=oke-vm-draining",
                ]
            )
          + "drain_pools"    = jsonencode(
                [
                  + "oke-vm-draining",
                ]
            )
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

```
module.workers_only.module.utilities[0].null_resource.drain_workers[0] (remote-exec): node/10.200.220.157 cordoned
module.workers_only.module.utilities[0].null_resource.drain_workers[0] (remote-exec): WARNING: ignoring DaemonSet-managed Pods: kube-system/csi-oci-node-99x74, kube-system/kube-flannel-ds-spvsp, kube-system/kube-proxy-6m2kk, ...
module.workers_only.module.utilities[0].null_resource.drain_workers[0] (remote-exec): node/10.200.220.157 drained
module.workers_only.module.utilities[0].null_resource.drain_workers[0]: Creation complete after 18s [id=7686343707387113624]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

Observe that the node(s) are now disabled for scheduling, and free of workloads other than DaemonSet-managed Pods when `worker_drain_ignore_daemonsets = true` (default):
```shell
kubectl get nodes -l oke.oraclecloud.com/pool.name=oke-vm-draining
NAME             STATUS                     ROLES   AGE   VERSION
10.200.220.157   Ready,SchedulingDisabled   node    24m   v1.26.2

kubectl get pods --all-namespaces --field-selector spec.nodeName=10.200.220.157
NAMESPACE     NAME                    READY   STATUS    RESTARTS   AGE
kube-system   csi-oci-node-99x74      1/1     Running   0          50m
kube-system   kube-flannel-ds-spvsp   1/1     Running   0          50m
kube-system   kube-proxy-6m2kk        1/1     Running   0          50m
kube-system   proxymux-client-2r6lk   1/1     Running   0          50m
```

Run the following command to uncordon a previously drained worker pool. The `drain = true` setting should be removed from the `worker_pools` entry to avoid re-draining the pool when running Terraform in the future.
```shell
kubectl uncordon -l oke.oraclecloud.com/pool.name=oke-vm-draining
node/10.200.220.157 uncordoned
```

## References
* [Safely Drain a Node](https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/)
* [`kubectl drain`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#drain)
* [Deleting a Worker Node](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengdeletingworkernodes.htm)

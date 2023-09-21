# Workers: Scaling

There are two easy ways to add worker nodes to a cluster:
* Add entries to `worker_pools`.
* Increase the `size` of a `worker_pools` entry.

Worker pools can be added and removed, their size and boot volume size can be updated. After each change, run `terraform apply`.

Scaling changes to the number and size of pools are immediate after changing the parameters and running `terraform apply`. The changes to boot volume size will only be effective in newly created nodes _after_ the change is completed.

## Autoscaling

See [Extensions/Cluster Autoscaler](../guide/extensions_cluster_autoscaler.md).

## Examples


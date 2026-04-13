# Worker Examples

Example configurations for various worker pool modes and features:

| File | Description |
|------|-------------|
| `vars-workers.auto.tfvars` | Basic worker pool defaults |
| `vars-workers-basic.auto.tfvars` | Simple node pool |
| `vars-workers-nodepool.auto.tfvars` | OKE-managed node pool |
| `vars-workers-virtualnodepool.auto.tfvars` | OKE-managed virtual node pool |
| `vars-workers-instance.auto.tfvars` | Self-managed compute instance |
| `vars-workers-instancepool.auto.tfvars` | Self-managed instance pool |
| `vars-workers-clusternetwork.auto.tfvars` | Cluster network (HPC/GPU with RDMA) |
| `vars-workers-computecluster.auto.tfvars` | Shared compute cluster |
| `vars-workers-autoscaling.auto.tfvars` | Autoscaled node pool |
| `vars-workers-advanced.auto.tfvars` | Advanced configuration options |
| `vars-workers-agent.auto.tfvars` | Management agent configuration |
| `vars-workers-cloudinit-global.auto.tfvars` | Global cloud-init for all pools |
| `vars-workers-cloudinit-pool.auto.tfvars` | Pool-specific cloud-init |
| `vars-workers-drain.auto.tfvars` | Worker pool draining |
| `vars-workers-network-nsgs.auto.tfvars` | Custom NSG configuration |
| `vars-workers-network-subnets.auto.tfvars` | Custom subnet configuration |
| `vars-workers-network-vnics.auto.tfvars` | Secondary VNIC configuration |
| `vars-workers-node-cycling.auto.tfvars` | Node cycling for updates |

## Usage

Copy the desired `.auto.tfvars` file(s) to your root module and adjust the values as needed.

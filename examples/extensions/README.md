# Extension Examples

Example configurations for deploying Kubernetes extensions:

| File | Extension | Description |
|------|-----------|-------------|
| `vars-extensions-argocd.auto.tfvars` | ArgoCD | GitOps continuous delivery |
| `vars-extensions-cilium.auto.tfvars` | Cilium | eBPF-based networking and security |
| `vars-extensions-cluster-autoscaler.auto.tfvars` | Cluster Autoscaler | Automatic node pool scaling |
| `vars-extensions-dcgm-exporter.auto.tfvars` | DCGM Exporter | GPU metrics for NVIDIA GPUs |
| `vars-extensions-gatekeeper.auto.tfvars` | Gatekeeper | OPA policy enforcement |
| `vars-extensions-metrics-server.auto.tfvars` | Metrics Server | Kubernetes metrics API |
| `vars-extensions-mpi-operator.auto.tfvars` | MPI Operator | MPI/NCCL distributed training jobs |
| `vars-extensions-multus.auto.tfvars` | Multus | Multi-network pod interfaces |
| `vars-extensions-prometheus.auto.tfvars` | Prometheus | Monitoring and alerting |
| `vars-extensions-rdma-cni.auto.tfvars` | RDMA CNI | RDMA network connections |
| `vars-extensions-service-account.auto.tfvars` | Service Accounts | Kubernetes service accounts with RBAC |
| `vars-extensions-sriov-cni.auto.tfvars` | SR-IOV CNI | SR-IOV network connections |
| `vars-extensions-sriov-device.auto.tfvars` | SR-IOV Device Plugin | SR-IOV network device advertisement |
| `vars-extensions-whereabouts.auto.tfvars` | Whereabouts | IP address management for Multus |

## Usage

Copy the desired `.auto.tfvars` file(s) to your root module and adjust the values as needed.

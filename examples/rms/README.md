# Oracle Resource Manager Stack Examples

Pre-built configurations for deploying via [OCI Resource Manager (ORM)](https://docs.oracle.com/en-us/iaas/Content/ResourceManager/home.htm):

| Stack | Description |
|-------|-------------|
| `oke-network-only` | Network infrastructure (VCN, subnets, NSGs, gateways, bastion, operator) |
| `oke-cluster-only` | Full OKE cluster deployment |
| `oke-workers-only` | Worker pools added to an existing cluster |

Each stack includes a `schema.yaml` for the Resource Manager UI.

## Usage

Upload the stack directory as a Terraform configuration in the OCI Console under Resource Manager > Stacks.

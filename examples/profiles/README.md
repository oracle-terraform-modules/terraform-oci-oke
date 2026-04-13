# Deployment Profiles

Composable deployment profiles that enable only the components you need:

| Profile | Description |
|---------|-------------|
| `network-only` | VCN, subnets, NSGs, and gateways only |
| `cluster-workers-only` | OKE cluster and worker pools (requires existing network) |
| `workers-only` | Worker pools only (requires existing cluster) |
| `network-cluster-workers` | Full stack: network, cluster, and workers |

## Usage

Each profile is a self-contained Terraform root module. Copy the profile directory and configure the variables.

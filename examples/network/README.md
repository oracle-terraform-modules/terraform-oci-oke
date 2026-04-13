# Network Examples

Example configurations for VCN networking:

| File | Description |
|------|-------------|
| `vars-network.auto.tfvars` | Full network configuration with subnets, NSGs, and gateways |
| `vars-network-subnets-create.auto.tfvars` | Automatic subnet creation with defaults |
| `vars-network-subnets-create-cidr.auto.tfvars` | Subnet creation with explicit CIDRs |
| `vars-network-subnets-create-cidr-ipv4-and-ipv6.tfvars` | Dual-stack (IPv4/IPv6) subnet creation |
| `vars-network-subnets-create-force.auto.tfvars` | Force subnet creation regardless of component settings |
| `vars-network-subnets-existing.auto.tfvars` | Using existing subnets |
| `vars-network-nsgs-create.auto.tfvars` | Creating network security groups |
| `vars-network-nsgs-existing.auto.tfvars` | Using existing NSGs |
| `vars-network-drg-create.auto.tfvars.example` | Creating a Dynamic Routing Gateway (example) |

## Usage

Copy the desired `.auto.tfvars` file(s) to your root module and adjust the values as needed.

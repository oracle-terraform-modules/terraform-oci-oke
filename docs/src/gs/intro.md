[uri-changelog]: ./CHANGELOG.md
[uri-oci-cli]: https://docs.oracle.com/en-us/iaas/Content/API/Concepts/cliconcepts.htm#Command_Line_Interface_CLI
[uri-oci-oke]: https://docs.oracle.com/en-us/iaas/Content/ContEng/home.htm#top
[uri-terraform-oci-vcn]: https://github.com/oracle-terraform-modules/terraform-oci-vcn
[uri-terraform-oci-bastion]: https://github.com/oracle-terraform-modules/terraform-oci-bastion
[uri-terraform-oci-operator]: https://github.com/oracle-terraform-modules/terraform-oci-operator
[uri-terraform-oci-drg]: https://github.com/oracle-terraform-modules/terraform-oci-drg
[uri-terraform-oci-oke]: https://github.com/oracle-terraform-modules/terraform-oci-oke
[uri-terraform-options]: ./inputs_submodule.html#cluster
# OCI Kubernetes Engine (OKE) Terraform Module

## Introduction

This module automates the provisioning of an [OKE][uri-oci-oke] cluster.

```admonish notice
The documentation here is for 5.x **only**. The documentation for earlier versions can be found on the [GitHub repo][uri-terraform-oci-oke] on the relevant branch.
```

```admonish warning
The documentation here is still being reorganised.
```

## News

***
### December 4, 2024: Announcing v5.2.2
- feat: add support to reference module nsgs in the nsg rules

### November 18, 2024: Announcing v5.2.1
- fix: operator custom cloud-init error by @mcouto-sossego in #950
- feat: added rules to allow UDP to be used for node port ranges by @robo-cap in #961

### November 7, 2024: Announcing v5.2.0
- Add support for stateless rules
- Fix KMS policy - cluster dependency
- Add cluster addon support
- Allow cloud-init update for nodepools
- Add several improvements and fixes
- Cilium extension upgrade to 1.16
- Fix pod nsg bug

### July 9, 2024: Announcing v5.1.8
- allow user to add additional rules to the workers NSG
-  docs: updated main page, mdbook component versions
-  Add support to ignore_initial_pool_size attribute on nodepools

<!-- ***
### August 24 2023: Announcing release v5.0.0-RC5

- docs: Push link to documentation further up in README
- fix: 5.x Distinguish A1 from A10 shape for image selection
- fix issues with the cluster_autoscaler defined_tags for worker nodes

***
### August 24 2023: Announcing release v5.0.0-RC4

- docs: updated releases
- fix: 5.x Include user-configured defined tags with cluster

***
### August 18 2023: Announcing release v5.0.0-RC3

- fix: 5.x Fallback to null for undefined subnet dns_label w/ assign_dns=false
- fix: missing lb rule doesn't allow explicit ingress from anywhere


### August 15 2023: Announcing release v5.0.0-RC2

- feat: 5.x Implement node_eviction_node_pool_settings
- docs: Add clarifying examples for operator instance principal
- fix: missing lb rule so load balancers become healthy
- feat: 5.x Update outputs for worker pools/ips/ids, eviction grace in seconds
- fix: fix ssh_to_operator output if create_bastion is false
- fix: 5.x Use locked dependency versions for GH mdbook cache
- fix: 5.x Subnet dns_label, cloud_init error handling, SSH command cleanup
- fix: 5.x Remove outdated Calico extension by @devoncrouse
- fix: 5.x Update Cluster Autoscaler docs, image tag
- fix: 5.x Evaluation for auto NSG creation with defaults


### July 20 2023: Announcing release v5.0.0-beta.6

- fix: 5.x Unspecified default placement FDs when mode != virtual-node-pool

### July 20 2023: Announcing release v5.0.0-RC1

- feat: Add 4.x->5.x migration blocks for subnets, cluster
- feat: 5.x Add extra network extensions, update docs/examples
- docs: docs updates
- fix: 5.x Remove unrequired home provider for bastion submodule
- fix: Update link to Oracle Contributor Agreement
- fix: 5.x Disable unused datasources, create NSGs with auto defaults
- fix: ssh_to_operator output use long form
- docs: improve formatting of examples/workers tfvars
- docs: improve formatting by putting more variables different lines
- fix: 5.x Use correct state_id var in resource tags
- feat: 5.x Implement worker pool drain
- feat: 5.x Implement virtual node pools

### June 27 2023: Announcing release v5.0.0-beta.5

- Safe handling of null values in strings on missing/destroy
- Error handling for tag lookups
- Update build action
- mdbook action, run for prefixed branche
- 1st doc review for 5.x
- Add missing resources tags, materialize early
- adding capacity reservation support for workers
- Add examples to documentation
- Fill in var defs for workers submodule, deprecate FSS inputs
- Flatten and tolist policy statements

### May 25 2023: Announcing release v5.0.0-beta.5

- Add optional NSG rule for bastion k8s endpoint access
- Add ability to override default cloud-init set by OKE in worker pools
- 5.x Use pool-level node_labels
- 5.x Use correct suffix numbering for pools with mode=instance
- 5.x Relax TF provider version constraints
- 5.x TF 1.3, subnet/NSG objects, NSG/image preconditions, unrequired VCN
- 5.x Support platform_config for preview modes
- 5.x Specify lifecycle ignore for extended_metadata at correct level
- 5.x Merge redundant shape results for platform_config type lookup
- Include empty default for pool extended_metadata

*** -->

### May 9 2023: Announcing release v4.5.9

- Make the default freeform_tags empty
- Use lower bound version specification for oci provider


## Related Documentation

* [VCN Module Documentation][uri-terraform-oci-vcn]
* [Bastion Module Documentation][uri-terraform-oci-bastion]
* [Operator Module Documentation][uri-terraform-oci-operator]
* [DRG Module Documentation][uri-terraform-oci-drg]

## Changelog
View the [CHANGELOG][uri-changelog].

## Security
Please consult the [security guide](./docs/SECURITY.md) for our responsible security vulnerability disclosure process


## License
Copyright (c) 2019-2023 Oracle and/or its affiliates.

Released under the Universal Permissive License v1.0 as shown at
<https://oss.oracle.com/licenses/upl/>.
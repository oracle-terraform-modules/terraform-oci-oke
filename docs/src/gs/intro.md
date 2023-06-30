[uri-changelog]: ./CHANGELOG.md
[uri-oci-cli]: https://docs.oracle.com/en-us/iaas/Content/API/Concepts/cliconcepts.htm#Command_Line_Interface_CLI
[uri-oci-oke]: https://docs.oracle.com/en-us/iaas/Content/ContEng/home.htm#top
[uri-terraform-oci-vcn]: https://github.com/oracle-terraform-modules/terraform-oci-vcn
[uri-terraform-oci-bastion]: https://github.com/oracle-terraform-modules/terraform-oci-bastion
[uri-terraform-oci-operator]: https://github.com/oracle-terraform-modules/terraform-oci-operator
[uri-terraform-oci-drg]: https://github.com/oracle-terraform-modules/terraform-oci-drg
[uri-terraform-oci-oke]: https://github.com/oracle-terraform-modules/terraform-oci-oke
[uri-terraform-options]: ./inputs_submodule.html#cluster
# Oracle Container Engine for Kubernetes (OKE) Terraform Module

## Introduction

This module automates the provisioning of an [OKE][uri-oci-oke] cluster.

```admonish notice
The documentation here is for 5.x **only**. The documentation for earlier versions can be found on the [GitHub repo][uri-terraform-oci-oke].
```

## News

***
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

***

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
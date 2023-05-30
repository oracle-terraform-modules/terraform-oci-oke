# Coding conventions

This project adheres to the following conventions:

- [Module structure](https://www.terraform.io/docs/language/modules/develop/structure.html)
- [Adopting the right case type]()
- [Good names for files and Terraform objects (resources, variables, outputs)]()

New conventions may be added to the list in future. All contributions should adhere to the list as published when the contribution is made.

Use PR comments and the GitHub suggestion feature to agree on the final result.

## Module Structure

- This project adheres to the {uri-terraform-standard-module-structure}[Terraform Standard Module Structure]
- Any nested module calls are in the appropriate `module-<name>.tf` file at the root of the project.
- All variables declarations must be in `variables.tf` or `variables-<group>.tf`
- All ouputs declarations must be in `outputs.tf`, `outputs-<group>.tf`, or colocated with their values.
- All variables and outputs must have descriptions.
- Nested modules must exist under the `modules` subdirectory.
- Examples of how to use the module must be placed in the `examples` subdirectory, with documentation under `docs`.

## Documentation format

This project uses Markdown with the `*.md` file extension.

###  HashiCorp Terraform Registry

- README files must be in Markdown format
- All links must use absolute path, relative links are not supported

## Terraform code

### Case type, Files, Names

- Use `snake_case` when naming Terraform files, variables and resources
- If you need a new .tf file for better clarity, use this naming scheme: `<resources_group>`: e.g. `subnets.tf`, `nsgs.tf`
- If your variable is controlling a behaviour, use imperative style to name it: e.g. `create_internet_gateway`, `use_cluster_encryption`

### Formatting

The following should be performed as needed before committing changes:
- Run `terraform fmt -recursive` from the project root directory.
- Run `tflint --recursive` from the project root directory (see [documentation here](https://github.com/terraform-linters/tflint)) and address new warnings.

### Variable blocks

Variables should always be in the format below:

```
variable "xyz" {
  default = "A default value"
  description:  "Add (Updatable) at the begining of the description if this value do not triggers a resource recreate"
  type: string
```

Variables exposed by the root module:

* must be included with its default value in the approriate tfvars example file.
* must define a default value that matches its type and will not alter existing behavior of the module.
* must define a description that describes how changes to the value will impact resources and interact with other variables when applicable.
* should be prefixed with the name of the component they pertain to unless shared across more than one, e.g. `worker_`, `operator_`, etc.
* should use imperative verbs when controlling behavior, e.g. `create`, `use`, etc.
* should include preconditions for input validation where possible.
* should prefer `null` for empty/unset defaults over empty string or other values.

Variables within submodules:

* must define only a type matching that of the root module.
* must omit defaults to ensure they are referenced from the root module.
* must omit descriptions to avoid maintaining in multiple places.
* should match the name of their root module counterparts, with the possible exception of a component prefix when redundant and unambiguous, e.g. `worker_`, `operator_`, etc.

Do not hesitate to insert a brief comment in the variable block if it helps to clarify your intention.

**WARNING:** No default value for `compartment_id` or any other variables related to provider authentication in module or examples files. The user will have to explicitly set these values.

### Examples

Examples should promote good practices as much as possible e.g. avoid creating resources in the tenancy root compartment. Please review the [OCI Security Guide](https://docs.oracle.com/en-us/iaas/Content/Security/Concepts/security_guide.htm).

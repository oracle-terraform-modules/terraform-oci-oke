PROJECT_NAME := "terraform-oci-oke"
SHELL = /usr/bin/env bash -o pipefail
.SHELLFLAGS = -ec

.PHONY: all
all: build

##@ General

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.terraform:
	terraform init

##@ Usage

.PHONY: plan
plan: .terraform ## Run terraform plan
	terraform plan

.PHONY: apply
apply: .terraform ## Run terraform apply
	terraform apply

.PHONY: ssh
ssh: ## Print SSH command
	terraform output -json | jq -rcM '.output.value.ssh_to_operator'

.PHONY: clean
clean: ## Clear Terraform module cache
	rm -rf ./.terraform

##@ Hygiene

.PHONY: fmt
fmt: ## Run terraform fmt
	terraform fmt -recursive .

.PHONY: validate
validate: ## Run terraform validate
	terraform validate

.PHONY: tflint
tflint: ## Run tflint
	tflint --recursive .

##@ Documentation

.PHONY: terraform-docs
terraform-docs:
	@command -v terraform-docs || go install github.com/terraform-docs/terraform-docs@v0.16.0

.PHONY: tfdocs.%
%.tfdocs:
	@echo "Generating terraform-docs for $(*)"
	@export HEADER="$(shell echo $* | tr a-z A-Z)" && \
	export TEMPLATE="<!-- BEGIN_TF_$${HEADER} -->\n{{ .Content }}\n\n<!-- END_TF_$${HEADER} -->" && \
	terraform-docs markdown table \
		--output-template "$${TEMPLATE}" \
		--output-file "../../docs/src/inputs_submodule.md" \
		-c docs/tfdocs-inputs.yml modules/$* && \
	export TEMPLATE="<!-- BEGIN_TF_$${HEADER} -->\n{{ .Content }}\n\n<!-- END_TF_$${HEADER} -->" && \
	terraform-docs markdown table \
		--output-template "$${TEMPLATE}" \
		--output-file "../../docs/src/outputs.md" \
		-c docs/tfdocs-outputs.yml modules/$* && \
	export TEMPLATE="<!-- BEGIN_TF_$${HEADER} -->\n{{ .Content }}\n\n<!-- END_TF_$${HEADER} -->" && \
	terraform-docs markdown table \
		--output-template "$${TEMPLATE}" \
		--output-file "../../docs/src/resources.md" \
		-c docs/tfdocs-resources.yml modules/$*

.PHONY: tfdocs
tfdocs: terraform-docs iam.tfdocs network.tfdocs bastion.tfdocs cluster.tfdocs workers.tfdocs operator.tfdocs ## Generate Terraform documentation
	@terraform-docs markdown table \
		--hide inputs,outputs,resources \
		--output-file "docs/src/dependencies.md" .
	@terraform-docs markdown table \
		-c docs/tfdocs-inputs.yml \
		--output-file "./docs/src/inputs_root.md" .

.PHONY: mdbook
mdbook:
	cargo install --locked --force mdbook@0.4.40 mdbook-admonish@1.18.0 mdbook-variables@0.2.4 mdbook-toc@0.14.2 mdbook-pagetoc@0.2.0 && \
	cd docs && mdbook-admonish install --css-dir src/css
.PHONY: mdbuild
mdbuild: mdbook tfdocs ## Generate documention
	mdbook build docs

.PHONY: mdserve
mdserve: mdbook tfdocs ## Generate documentation and start a local web server
	mdbook serve docs


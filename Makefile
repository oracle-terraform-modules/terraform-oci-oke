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

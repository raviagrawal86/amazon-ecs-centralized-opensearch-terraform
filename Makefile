.ONESHELL:
SHELL := /bin/bash

TF_SHARED_SERVICES=$$(pwd)/tf-shared-services
TF_COMPUTE_DIR=$$(pwd)/tf-compute

all: format lint docs checkov validate

.PHONY: create-shared-services
create-shared-services:
	set -e
	echo tf-shared-services-create: Start
	terraform -chdir=$(TF_SHARED_SERVICES) init -upgrade
	terraform -chdir=$(TF_SHARED_SERVICES) apply --auto-approve
	echo tf-shared-services-create: Success

.PHONY: destroy-shared-services
destroy-shared-services:
	set -e
	echo tf-shared-services-destroy: Start
	terraform -chdir=$(TF_SHARED_SERVICES) init -upgrade
	terraform -chdir=$(TF_SHARED_SERVICES) destroy --auto-approve
	echo tf-shared-services-destroy: Success

.PHONY: create-compute
create-compute:
	set -e
	echo tf-compute-create: Start
	terraform -chdir=$(TF_COMPUTE_DIR) init -upgrade
	terraform -chdir=$(TF_COMPUTE_DIR) apply --auto-approve
	echo tf-compute-create: Success

.PHONY: destroy-compute
destroy-compute:
	set -e
	echo tf-compute-destroy: Start
	terraform -chdir=$(TF_COMPUTE_DIR) init -upgrade
	terraform -chdir=$(TF_COMPUTE_DIR) destroy --auto-approve
	echo tf-compute-destroy: Success

.SILENT:
format:
	set -e

	echo tf-fmt: Start

	terraform fmt -list=true -recursive .

	echo tf-fmt: Success

.SILENT:
lint:
	set -e

	echo tf-lint: Start

	tflint --recursive

	echo tf-lint: Success

.SILENT:
checkov:
	set -e
	echo checkov: Start
	checkov -d . --quiet
	echo checkov: Success

.SILENT:
docs:
	set -e
	echo documentation update: Start
	terraform-docs markdown table --output-file README.md --output-mode inject $(TF_SHARED_SERVICES)/modules/opensearchserverless
	terraform-docs markdown table --output-file README.md --output-mode inject $(TF_SHARED_SERVICES)
	terraform-docs markdown table --output-file README.md --output-mode inject $(TF_COMPUTE_DIR)
	echo documentation update: Success


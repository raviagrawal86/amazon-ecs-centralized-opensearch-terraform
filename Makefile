.ONESHELL:
SHELL := /bin/bash

TF_SETUP_DIR=$$(pwd)/tf-setup
TF_ECS_DIR=$$(pwd)/tf-ecs

all: format lint docs checkov validate

.PHONY: create-setup
create-setup:
	set -e
	echo tf-setup-create: Start
	terraform -chdir=$(TF_SETUP_DIR) init -upgrade
	terraform -chdir=$(TF_SETUP_DIR) apply --auto-approve
	echo tf-setup-create: Success

.PHONY: destroy-setup
destroy-setup:
	set -e
	echo tf-setup-destroy: Start
	terraform -chdir=$(TF_SETUP_DIR) init -upgrade
	terraform -chdir=$(TF_SETUP_DIR) destroy --auto-approve
	echo tf-setup-destroy: Success

.PHONY: create-core
create-core:
	set -e
	echo tf-core-create: Start
	terraform -chdir=$(TF_ECS_DIR) init -upgrade
	terraform -chdir=$(TF_ECS_DIR) apply --auto-approve
	echo tf-core-create: Success

.PHONY: destroy-core
destroy-core:
	set -e
	echo tf-core-destroy: Start
	terraform -chdir=$(TF_ECS_DIR) init -upgrade
	terraform -chdir=$(TF_ECS_DIR) destroy --auto-approve
	echo tf-core-destroy: Success

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


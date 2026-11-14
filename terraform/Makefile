# Manage the Oracle Terraform root.
#   make init
#   make plan
#   make apply
#   make encrypt-all
#   make decrypt-all
#   make cleanup

.PHONY: help init plan apply

help:
	@echo "targets: init plan apply encrypt-all decrypt-all cleanup"

init:
	terraform init

plan:
	terraform plan

apply:
	terraform apply

BINARY := \
	terraform.tfvars terraform.tfvars.enc \
	terraform.tfstate terraform.tfstate.enc \
	terraform.tfstate.backup terraform.tfstate.backup.enc \
	generated/kubeconfig generated/kubeconfig.enc \
	generated/worker_ed25519 generated/worker_ed25519.enc \
	generated/mattermost_db_password generated/mattermost_db_password.enc

include ../shared/Makefile

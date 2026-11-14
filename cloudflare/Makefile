# Manage the Cloudflare Terraform root.
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
	generated/tunnel_token generated/tunnel_token.enc

include ../shared/Makefile

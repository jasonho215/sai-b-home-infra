# Manage the cluster releases.
#   make connect
#   make apply
#   make platform
#   make mattermost
#   make encrypt-all
#   make decrypt-all
#   make cleanup

OCI_CLI_PROFILE ?= sai-b-home-agent
LOCAL_API_PORT ?= 6443
SESSION_TTL ?= 10800
BASTION_KEY := generated/bastion_ed25519
KUBECONFIG_FILE := generated/kubeconfig

export OCI_CLI_PROFILE
export LOCAL_API_PORT
export SUPPRESS_LABEL_WARNING ?= True
export OCI_CLI_SUPPRESS_FILE_PERMISSIONS_WARNING ?= True
export KUBECONFIG ?= $(CURDIR)/$(KUBECONFIG_FILE)

.PHONY: help apply platform mattermost connect

help:
	@echo "targets: connect apply platform mattermost encrypt-all decrypt-all cleanup"

apply: platform mattermost

connect: $(BASTION_KEY).pub
	@set -e; \
	mkdir -p generated; \
	bastion_id="$$(terraform -chdir=../terraform output -raw bastion_id)"; \
	cluster_id="$$(terraform -chdir=../terraform output -raw cluster_id)"; \
	api_endpoint="$$(terraform -chdir=../terraform output -raw kubernetes_api_endpoint)"; \
	api_ip="$${api_endpoint%%:*}"; \
	api_port="$${api_endpoint##*:}"; \
	region="$$(printf '%s' "$$bastion_id" | cut -d. -f4)"; \
	if lsof -nP -iTCP:$(LOCAL_API_PORT) -sTCP:LISTEN | grep -q '127.0.0.1:$(LOCAL_API_PORT)'; then \
		if ! lsof -nP -iTCP:$(LOCAL_API_PORT) -sTCP:LISTEN | grep '127.0.0.1:$(LOCAL_API_PORT)' | grep -q ssh; then \
			echo "127.0.0.1:$(LOCAL_API_PORT) is already in use" >&2; \
			exit 1; \
		fi; \
		echo "bastion forward already listening on 127.0.0.1:$(LOCAL_API_PORT)"; \
	else \
		session_id="$$(oci bastion session list --bastion-id "$$bastion_id" --all --output json | python3 find-bastion-session.py "$$api_ip" "$$api_port" $(BASTION_KEY).pub)"; \
		if [ -z "$$session_id" ]; then \
			session_id="$$(oci bastion session create-port-forwarding \
				--bastion-id "$$bastion_id" \
				--ssh-public-key-file $(BASTION_KEY).pub \
				--target-private-ip "$$api_ip" \
				--target-port "$$api_port" \
				--session-ttl $(SESSION_TTL) \
				--display-name k8s-api \
				--query 'data.id' --raw-output)"; \
			echo "waiting for bastion session"; \
			i=0; \
			while [ "$$i" -lt 60 ]; do \
				state="$$(oci bastion session get --session-id "$$session_id" --query 'data."lifecycle-state"' --raw-output)"; \
				if [ "$$state" = ACTIVE ]; then break; fi; \
				if [ "$$state" = FAILED ] || [ "$$state" = DELETED ]; then \
					echo "bastion session $$state" >&2; \
					exit 1; \
				fi; \
				i=$$((i + 1)); \
				sleep 2; \
			done; \
			if [ "$$state" != ACTIVE ]; then echo "bastion session did not become ACTIVE" >&2; exit 1; fi; \
		else \
			echo "reusing bastion session"; \
		fi; \
		n=0; \
		until ssh -i $(BASTION_KEY) \
			-o IdentitiesOnly=yes \
			-o StrictHostKeyChecking=accept-new \
			-o ExitOnForwardFailure=yes \
			-o ServerAliveInterval=30 \
			-o ServerAliveCountMax=3 \
			-N -L 127.0.0.1:$(LOCAL_API_PORT):$$api_ip:$$api_port \
			-p 22 -f \
			"$$session_id@host.bastion.$$region.oci.oraclecloud.com"; do \
			n=$$((n + 1)); \
			if [ "$$n" -ge 10 ]; then echo "bastion ssh forward failed" >&2; exit 1; fi; \
			sleep 3; \
		done; \
	fi; \
	rm -f $(KUBECONFIG_FILE); \
	oci ce cluster create-kubeconfig \
		--cluster-id "$$cluster_id" \
		--file $(KUBECONFIG_FILE) \
		--region "$$region" \
		--token-version 2.0.0 \
		--kube-endpoint PRIVATE_ENDPOINT; \
	python3 patch-kubeconfig.py $(KUBECONFIG_FILE); \
	echo "export OCI_CLI_PROFILE=$(OCI_CLI_PROFILE)"; \
	echo "export KUBECONFIG=$(CURDIR)/$(KUBECONFIG_FILE)"

platform:
	@test -f "$$KUBECONFIG" || { echo "run make connect first"; exit 1; }
	@test -f secrets.yaml || { echo "run make decrypt-all from the repository root first"; exit 1; }
	helm upgrade --install platform ./platform --namespace platform --create-namespace \
		-f platform/values.yaml \
		-f secrets.yaml \
		--wait --timeout 10m

mattermost:
	@test -f "$$KUBECONFIG" || { echo "run make connect first"; exit 1; }
	@test -f secrets.yaml || { echo "run make decrypt-all from the repository root first"; exit 1; }
	@test -f mattermost-values.yaml || { echo "run make decrypt-all from the repository root first"; exit 1; }
	helm repo add mattermost https://helm.mattermost.com
	helm upgrade --install mattermost mattermost/mattermost-team-edition \
		--namespace mattermost \
		--create-namespace \
		-f mattermost-values.yaml \
		--wait --timeout 10m

$(BASTION_KEY):
	mkdir -p $(dir $@)
	ssh-keygen -t ed25519 -f $@ -N "" -q
	chmod 600 $@

$(BASTION_KEY).pub: $(BASTION_KEY)
	@test -s $@ || ssh-keygen -y -f $(BASTION_KEY) > $@

YAML_PLAIN := secrets.yaml
YAML_ENC := secrets.enc.yaml
YAML_FILES := mattermost-values.yaml mattermost-values.enc.yaml

include ../shared/Makefile

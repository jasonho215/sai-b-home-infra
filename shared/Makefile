# Shared secret operations. Include this from a module Makefile.
# Set BINARY to plaintext/ciphertext pairs. Paths are relative to the module.
# Optionally set YAML_PLAIN and YAML_ENC for one SOPS yaml file.
# YAML_FILES is extra plaintext/ciphertext pairs, same shape as BINARY.

SOPS ?= sops

.PHONY: encrypt-all decrypt-all cleanup

encrypt-all:
	@set -e; \
	set -- $(BINARY); \
	while [ "$$#" -ge 2 ]; do \
		src="$$1"; dest="$$2"; shift 2; \
		if [ ! -f "$$src" ]; then echo "skip $$src"; continue; fi; \
		echo "encrypt $$src"; \
		$(SOPS) encrypt --input-type binary --output-type json \
			--filename-override "$$dest" --output "$$dest" "$$src"; \
		chmod 644 "$$dest"; \
	done; \
	yaml_plain='$(YAML_PLAIN)'; yaml_enc='$(YAML_ENC)'; \
	if [ -z "$$yaml_plain" ]; then \
		:; \
	elif [ ! -f "$$yaml_plain" ]; then \
		echo "skip $$yaml_plain"; \
	else \
		echo "encrypt $$yaml_plain"; \
		$(SOPS) encrypt --filename-override "$$yaml_enc" --output "$$yaml_enc" "$$yaml_plain"; \
		chmod 644 "$$yaml_enc"; \
	fi; \
	set -- $(YAML_FILES); \
	while [ "$$#" -ge 2 ]; do \
		src="$$1"; dest="$$2"; shift 2; \
		if [ ! -f "$$src" ]; then echo "skip $$src"; continue; fi; \
		echo "encrypt $$src"; \
		$(SOPS) encrypt --filename-override "$$dest" --output "$$dest" "$$src"; \
		chmod 644 "$$dest"; \
	done

decrypt-all:
	@set -e; \
	set -- $(BINARY); \
	while [ "$$#" -ge 2 ]; do \
		src="$$1"; dest="$$2"; shift 2; \
		echo "decrypt $$dest"; \
		$(SOPS) decrypt --output-type binary --output "$$src" "$$dest"; \
		chmod 600 "$$src"; \
	done; \
	yaml_plain='$(YAML_PLAIN)'; yaml_enc='$(YAML_ENC)'; \
	if [ -n "$$yaml_enc" ]; then \
		echo "decrypt $$yaml_enc"; \
		$(SOPS) decrypt --output "$$yaml_plain" "$$yaml_enc"; \
		chmod 600 "$$yaml_plain"; \
	fi; \
	set -- $(YAML_FILES); \
	while [ "$$#" -ge 2 ]; do \
		src="$$1"; dest="$$2"; shift 2; \
		echo "decrypt $$dest"; \
		$(SOPS) decrypt --output "$$src" "$$dest"; \
		chmod 600 "$$src"; \
	done

cleanup:
	@set -e; \
	set -- $(BINARY); \
	while [ "$$#" -ge 2 ]; do \
		src="$$1"; dest="$$2"; shift 2; \
		if [ ! -f "$$src" ]; then echo "skip $$src"; continue; fi; \
		if [ ! -f "$$dest" ]; then echo "keep $$src (missing $$dest)"; continue; fi; \
		echo "remove $$src"; \
		rm -f "$$src"; \
	done; \
	yaml_plain='$(YAML_PLAIN)'; yaml_enc='$(YAML_ENC)'; \
	if [ -z "$$yaml_plain" ] || [ ! -f "$$yaml_plain" ]; then \
		if [ -n "$$yaml_plain" ]; then echo "skip $$yaml_plain"; fi; \
	elif [ ! -f "$$yaml_enc" ]; then \
		echo "keep $$yaml_plain (missing $$yaml_enc)"; \
	else \
		echo "remove $$yaml_plain"; \
		rm -f "$$yaml_plain"; \
	fi; \
	set -- $(YAML_FILES); \
	while [ "$$#" -ge 2 ]; do \
		src="$$1"; dest="$$2"; shift 2; \
		if [ ! -f "$$src" ]; then echo "skip $$src"; continue; fi; \
		if [ ! -f "$$dest" ]; then echo "keep $$src (missing $$dest)"; continue; fi; \
		echo "remove $$src"; \
		rm -f "$$src"; \
	done

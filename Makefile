# Delegate secret operations to each module.
#   make encrypt-all
#   make decrypt-all
#   make cleanup

MODULES := terraform cloudflare k8s

.PHONY: encrypt-all decrypt-all cleanup

encrypt-all decrypt-all cleanup:
	@set -e; \
	for module in $(MODULES); do \
		echo "==> $$module $@"; \
		$(MAKE) -C $$module $@; \
	done

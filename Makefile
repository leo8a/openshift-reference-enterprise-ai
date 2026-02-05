MAKEFLAGS += --no-print-directory

# =============================================================================
# Path Configuration
# =============================================================================
REFERENCE_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
METADATA_FILE := $(REFERENCE_DIR)/metadata.yaml

# =============================================================================
# Validation Configuration
# =============================================================================
KUBE_COMPARE ?= $(REFERENCE_DIR)/bin/kubectl-cluster_compare


# ───────────────────────────────────────────────────────────────────────────────
# Default Target
# ───────────────────────────────────────────────────────────────────────────────

default: help


##@ Validation

.PHONY: validate-enterprise-ai-reference
validate-enterprise-ai-reference: ## Validate OpenShift cluster against Enterprise AI reference
	@echo "Validating cluster against Enterprise AI reference..."
	@echo "Reference: $(METADATA_FILE)"
	@$(KUBE_COMPARE) -r $(METADATA_FILE)


##@ Help

.PHONY: help
help: ## Display available targets
	@awk 'BEGIN {printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5); } /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-30s\033[0m %s\n", $$1, substr($$0, index($$0, $$3)); }' $(MAKEFILE_LIST)

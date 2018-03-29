# Include this partial Makefile if your repo is a fork of an upstream
# and you want to quickly merge commits from upstream.

# Requirements:
# - the upstream repo is a git submodule, found in $(UPSTREAM_DIR)

UPSTREAM_DIR := upstream

# ------------------------------------------------------------------------------

.PHONY: merge-upstream/%
merge-upstream/%: ## Merge a commit-ish from upstream.
	cd $(UPSTREAM_DIR) && { \
		$(GIT) fetch; \
		$(GIT) fetch --tags; \
	}
	$(GIT) remote | $(GREP) -q "upstream" || \
		$(GIT) remote add upstream $(UPSTREAM_DIR)
	$(GIT) fetch upstream
	$(GIT) fetch --tags upstream
	if $(GIT) rev-parse upstream/$* >/dev/null 2>&1; then \
		$(GIT) merge --no-ff upstream/$*; \
	else \
		$(GIT) merge --no-ff $*; \
	fi

# Adds phony targets to install all npm dependencies `deps-npm`, and prod-only `deps-npm-prod`.
# Additionally to 'npm install' functionality, we also:
# * install babel-preset-firecloud and eslint-config-firecloud peer dependencies
# * 'npm update' also the git dependencies (to the latest compatible version)
# * check (and fail) for unmet peer dependencies.
#
# The check for unmet peer dependencies can be silenced on a case-by-case basis
# by commiting a package.json.unmet-peer file that contains the 'peer dep missing' lines
# produced by 'npm list' that you want to ignore e.g.:
# npm ERR! peer dep missing: tslint@^5.16.0, required by tslint-config-firecloud
#
# ------------------------------------------------------------------------------

NPM = $(call which,NPM,npm)
$(foreach VAR,NPM,$(call make-lazy,$(VAR)))

SF_CLEAN_FILES := \
	$(SF_CLEAN_FILES) \
	node_modules \

SF_DEPS_TARGETS := \
	$(SF_DEPS_TARGETS) \
	deps-npm \

ifdef SF_ECLINT_FILES_IGNORE
SF_ECLINT_FILES_IGNORE := \
	$(SF_ECLINT_FILES_IGNORE) \
	-e "^package-lock.json$$" \
	-e "^package.json.unmet-peer$$" \

endif

# ------------------------------------------------------------------------------

.PHONY: deps-npm-unmet-peer
deps-npm-unmet-peer:
	$(eval NPM_LIST_TMP := $(shell $(MKTEMP)))
	$(eval UNMET_PEER_DIFF_TMP := $(shell $(MKTEMP)))
	$(NPM) list --depth=0 >$(NPM_LIST_TMP) 2>&1 || true
	diff -U0 \
		<(cat package.json.unmet-peer 2>/dev/null | \
			$(GREP) --only-matching -e "npm ERR! peer dep missing: [^,]\+, required by @\?[^@]\+" | \
			$(SORT) -u || true) \
		<(cat $(NPM_LIST_TMP) 2>/dev/null | \
			$(GREP) --only-matching -e "npm ERR! peer dep missing: [^,]\+, required by @\?[^@]\+" | \
			$(SORT) -u || true) \
		>$(UNMET_PEER_DIFF_TMP) || $(TOUCH) $(UNMET_PEER_DIFF_TMP)
	if $(CAT) $(UNMET_PEER_DIFF_TMP) | $(GREP) -q -e "^\+npm"; then \
		$(ECHO_ERR) "Found new unmet peer dependencies."; \
		$(ECHO_INFO) "If you cannot fix the unmet peer dependencies, and want to ignore them instead,"; \
		$(ECHO_INFO) "please edit package.json.unmet-peer, and append these line(s):"; \
		$(CAT) $(UNMET_PEER_DIFF_TMP) | $(GREP) -e "^\+npm" | $(SED) "s/^\+//g"; \
		$(ECHO); \
	fi
	if $(CAT) $(UNMET_PEER_DIFF_TMP) | $(GREP) -q -e "^\-npm"; then \
		$(ECHO_ERR) "Found outdated unmet peer dependencies."; \
		$(ECHO_INFO) "Please edit package.json.unmet-peer, and remove these line(s):"; \
		$(CAT) $(UNMET_PEER_DIFF_TMP) | $(GREP) -e "^\-npm" | $(SED) "s/^\-//g"; \
		$(ECHO); \
	fi
	if [[ -s $(UNMET_PEER_DIFF_TMP) ]]; then \
		exit 1; \
	fi


.PHONY: deps-npm
deps-npm:
	$(eval NPM_LOGS_DIR := $(shell $(NPM) config get cache)/_logs)
	$(NPM) install || { \
		$(CAT) $(NPM_LOGS_DIR)/`ls -t $(NPM_LOGS_DIR) | $(HEAD) -1` | \
			$(GREP) -q "No matching version found for" && \
			$(NPM) install; \
	}
	if [[ -x node_modules/babel-preset-firecloud/npm-install-peer-dependencies ]]; then \
		node_modules/babel-preset-firecloud/npm-install-peer-dependencies; \
	fi
	if [[ -x node_modules/eslint-config-firecloud/npm-install-peer-dependencies ]]; then \
		node_modules/eslint-config-firecloud/npm-install-peer-dependencies; \
	fi
ifeq ($(CI),true)
	$(GIT) diff --exit-code package.json || { \
		$(ECHO_ERR) "package.json has changed."; \
		$(ECHO_ERR) "Run 'make deps-npm' locally, commit and push the changes before another CI run."; \
		exit 1; \
	}
endif
	$(NPM) prune
	[[ -f "package-lock.json" ]] || { \
		$(CAT) package.json | \
			$(JQ)  ".dependencies + .devDependencies" | \
			$(JQ) "to_entries" | \
			$(JQ) ".[] | select(.value | contains(\"git\"))" | \
			$(JQ) -r ".key" | \
			$(XARGS) -L1 -I{} $(RM) node_modules/{}; \
		$(NPM) update --no-save --development; \
	}
	$(NPM) list --depth=0 || $(MAKE) deps-npm-unmet-peer


.PHONY: deps-npm-prod
deps-npm-prod:
	$(NPM) install --production
	$(NPM) prune --production
	[[ -f "package-lock.json" ]] || { \
		$(CAT) package.json | \
			$(JQ)  ".dependencies" | \
			$(JQ) "to_entries" | \
			$(JQ) ".[] | select(.value | contains(\"git\"))" | \
			$(JQ) -r ".key" | \
			$(XARGS) -L1 -I{} $(RM) node_modules/{}; \
		$(NPM) update --no-save --production; \
	}
	$(NPM) list --depth=0 || $(MAKE) deps-npm-unmet-peer

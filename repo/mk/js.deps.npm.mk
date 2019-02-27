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

endif

# ------------------------------------------------------------------------------

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
	$(NPM) list --depth=0


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
	$(NPM) list --depth=0

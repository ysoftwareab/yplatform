# Adds 'deps-npm' and 'deps-npm-prod' internal targets to install all and respectively prod-only npm dependencies.
# The 'deps-npm' target is automatically included in the 'deps' target via YP_DEPS_TARGETS.
#
# In addition to 'npm install' functionality, we also:
# * install babel-preset-firecloud and eslint-plugin-firecloud peer dependencies
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

NPM_CI_OR_INSTALL := install
ifeq ($(CI),true)
ifneq (,$(wildcard package-lock.json))
# npm ci doesn't play nice with git dependencies
ifeq (,$(shell $(CAT) package.json | \
	$(JQ) ".dependencies + .devDependencies" | \
	$(JQ) "to_entries" | \
	$(JQ) ".[] | select(.value | contains(\"git\"))" | \
	$(JQ) -r ".key"))
NPM_CI_OR_INSTALL := ci
endif
endif
endif

YP_CLEAN_FILES += \
	node_modules \

YP_DEPS_TARGETS += \
	deps-npm \

YP_CHECK_TARGETS += \
	check-package-json \
	check-package-lock-json \

ifdef YP_ECCHECKER_FILES_IGNORE
YP_ECCHECKER_FILES_IGNORE += \
	-e "^package-lock.json$$" \
	-e "^package.json.unmet-peer$$" \

endif

# ------------------------------------------------------------------------------

.PHONY: deps-npm-unmet-peer
deps-npm-unmet-peer:
	$(eval NPM_LIST_TMP := $(shell $(MKTEMP)))
	$(eval UNMET_PEER_DIFF_TMP := $(shell $(MKTEMP)))
	$(NPM) list --depth=0 >$(NPM_LIST_TMP) 2>&1 || true
	$(DIFF) -U0 \
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


.PHONY: deps-npm-ci
deps-npm-ci:
	$(NPM) ci


.PHONY: deps-npm-install
deps-npm-install:
	$(eval PACKAGE_JSON_WAS_CHANGED := $(shell $(GIT) diff --exit-code package.json >/dev/null && \
		$(ECHO) false || $(ECHO) true))
	[[ ! -f "package-lock.json" ]] || { \
		[[ "$$($(NPM) config get package-lock)" = "true" ]] || { \
			$(ECHO_ERR) "npm's package-lock flag is not on. Please check your .npmrc file."; \
			exit 1; \
		}; \
	}
	$(NPM) install
#	convenience. install peer dependencies from babel/eslint firecloud packages
	[[ ! -f node_modules/babel-preset-firecloud/package.json ]] || \
		$(YP_DIR)/bin/npm-install-peer-deps node_modules/babel-preset-firecloud/package.json
	[[ ! -f node_modules/eslint-plugin-firecloud/package.json ]] || \
		$(YP_DIR)/bin/npm-install-peer-deps node_modules/eslint-plugin-firecloud/package.json
#	deprecated
	[[ ! -f node_modules/eslint-config-firecloud/package.json ]] || \
		$(YP_DIR)/bin/npm-install-peer-deps node_modules/eslint-config-firecloud/package.json
#	sort dependencies in package.json
	$(CAT) package.json | \
		$(JQ) ". \
			+ (if .dependencies \
				then {dependencies: (.dependencies|to_entries|sort_by(.key)|from_entries)} \
				else .dependencies \
				end) \
			+ (if .devDependencies \
				then {devDependencies: (.devDependencies|to_entries|sort_by(.key)|from_entries)} \
				else .devDependencies \
				end) \
		" | \
		${YP_DIR}/bin/sponge package.json
#	check that installing peer dependencies didn't modify package.json
	$(GIT) diff --exit-code package.json || [[ "$(PACKAGE_JSON_WAS_CHANGED)" = "true" ]] || { \
		$(NPM) install; \
		$(ECHO_ERR) "package.json has changed."; \
		$(ECHO_ERR) "Please review and commit the changes."; \
		exit 1; \
	}
#	remove extraneous dependencies
	$(NPM) prune
#	update git dependencies with semver range. 'npm install' doesn't
	[[ -f "package-lock.json" ]] || { \
		$(CAT) package.json | \
			$(JQ)  ".dependencies + .devDependencies" | \
			$(JQ) "to_entries" | \
			$(JQ) ".[] | select(.value | contains(\"git\"))" | \
			$(JQ) -r ".key" | \
			$(XARGS) -I{} $(RM) node_modules/{}; \
		$(NPM) update --no-save --development; \
	}


.PHONY: deps-npm
deps-npm:
	$(ECHO_INFO) "NODE=$(NODE) $(shell $(NODE) --version)"
	$(ECHO_INFO) "NPM=$(NPM) $(shell $(NPM) --version)"
	$(NPM) config list
	$(ECHO_INFO) "Running 'npm $(NPM_CI_OR_INSTALL)'."
#	'npm ci' should be more stable and faster if there's a 'package-lock.json'
	$(MAKE) deps-npm-$(NPM_CI_OR_INSTALL)
	$(NPM) list --depth=0 || $(MAKE) deps-npm-unmet-peer


.PHONY: deps-npm-ci-prod
deps-npm-ci-prod:
	$(NPM) ci


.PHONY: deps-npm-install-prod
deps-npm-install-prod:
	[[ ! -f "package-lock.json" ]] || { \
		[[ "$$($(NPM) config get package-lock)" = "true" ]] || { \
			$(ECHO_ERR) "npm's package-lock flag is not on. Please check your .npmrc file."; \
			exit 1; \
		}; \
	}
	$(NPM) install --production
#	remove extraneous dependencies
	$(NPM) prune --production
#	update git dependencies with semver range. 'npm install' doesn't
	[[ -f "package-lock.json" ]] || { \
		$(CAT) package.json | \
			$(JQ)  ".dependencies + .devDependencies" | \
			$(JQ) "to_entries" | \
			$(JQ) ".[] | select(.value | contains(\"git\"))" | \
			$(JQ) -r ".key" | \
			$(XARGS) -I{} $(RM) node_modules/{}; \
		$(NPM) update --no-save --production; \
	}


.PHONY: deps-npm-prod
deps-npm-prod:
	$(ECHO_INFO) "NODE=$(NODE) $(shell $(NODE) --version)"
	$(ECHO_INFO) "NPM=$(NPM) $(shell $(NPM) --version)"
	$(NPM) config list
	$(ECHO_INFO) "Running 'npm $(NPM_CI_OR_INSTALL)'."
#	'npm ci' should be more stable and faster if there's a 'package-lock.json'
	$(MAKE) deps-npm-$(NPM_CI_OR_INSTALL)-prod
	$(NPM) list --depth=0 || $(MAKE) deps-npm-unmet-peer


.PHONY: check-package-json
check-package-json:
	$(GIT) diff --exit-code package.json || { \
		$(ECHO_ERR) "package.json has changed. Please commit your changes."; \
		exit 1; \
	}


.PHONY: check-package-lock-json
check-package-lock-json: check-package-json
	$(eval PACKAGE_JSON_HASH := $(shell $(GIT) log -1 --format='%h' -- package.json))
	$(eval PACKAGE_LOCK_JSON_HASH := $(shell $(GIT) log -1 --format='%h' -- package-lock.json))
	$(eval JQ_EXPR := "{a: .name, b: .version, c: .dependencies, d: .devDependencies}")
	if $(GIT_LS) | $(GREP) -q "^package-lock.json$$"; then \
		$(GIT) diff --exit-code package-lock.json || { \
			$(ECHO_ERR) "package-lock.json has changed. Please commit your changes."; \
			exit 1; \
		}; \
		$(DIFF) \
			<($(GIT) show $(PACKAGE_LOCK_JSON_HASH):package.json | $(JQ) -S $(JQ_EXPR)) \
			<($(GIT) show $(PACKAGE_JSON_HASH):package.json | $(JQ) -S $(JQ_EXPR)) || { \
			$(ECHO_ERR) "package.json dependencies have changed without package-lock.json getting updated."; \
			$(ECHO_INFO) "package.json modified last at $(PACKAGE_JSON_HASH)"; \
			$(ECHO_INFO) "package-lock.json modified last at $(PACKAGE_LOCK_JSON_HASH)"; \
			$(ECHO_INFO) "Please run 'make deps-npm' and commit your changes to package-lock.json."; \
			exit 1; \
		}; \
	fi

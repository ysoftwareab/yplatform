# Adds 'deps-npm' and 'deps-npm-prod' internal targets to install all and respectively prod-only npm dependencies.
# The 'deps-npm' target is automatically included in the 'deps' target via SF_DEPS_TARGETS.
#
# In addition to 'npm install' functionality, we also:
# * install babel-preset-firecloud and eslint-config-firecloud peer dependencies
# * 'npm update' also the git dependencies (to the latest compatible version)
# * check (and fail) for unmet peer dependencies.
#
# The check for unmet peer dependencies can be silenced on a case-by-case basis
# by commiting a package.json.unmet-peer file that contains the 'peer dep missing' lines
# produced by 'npm list' that you want to ignore e.g.:
# npm ERR! peer dep missing: tslint@^5.16.0, required by tslint-config-firecloud
#
# For leaf repositories (i.e. not libraries), package-lock.json may present some stability.
# In order to create a lock, add to your Makefile:
# SF_DEPS_TARGETS += deps-npm-package-lock
# and commit package-lock.json.
#
# ------------------------------------------------------------------------------

NPM = $(call which,NPM,npm)
$(foreach VAR,NPM,$(call make-lazy,$(VAR)))

SF_CLEAN_FILES += \
	node_modules \

SF_DEPS_TARGETS += \
	deps-npm \

SF_CHECK_TARGETS += \
	check-package-json \
	check-package-lock-json \

ifdef SF_ECLINT_FILES_IGNORE
SF_ECLINT_FILES_IGNORE += \
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
	$(eval PACKAGE_JSON_WAS_CHANGED := $(shell $(GIT) diff --exit-code package.json && echo false || echo true))
#	install. 'npm ci' should be more stable and faster if there's a 'package-lock.json'
ifeq (true,$(CI))
	$(NPM) ci
else
	$(NPM) install
#	convenience. install peer dependencies from babel/eslint firecloud packages
	if [[ -x node_modules/babel-preset-firecloud/npm-install-peer-dependencies ]]; then \
		node_modules/babel-preset-firecloud/npm-install-peer-dependencies; \
	fi
	if [[ -x node_modules/eslint-config-firecloud/npm-install-peer-dependencies ]]; then \
		node_modules/eslint-config-firecloud/npm-install-peer-dependencies; \
	fi
#	check that installing peer dependencies didn't modify package.json
	$(GIT) diff --exit-code package.json || [[ "$(PACKAGE_JSON_WAS_CHANGED)" = "true" ]] || { \
		$(ECHO_ERR) "package.json has changed."; \
		$(ECHO_ERR) "Run 'make deps-npm' locally, commit and push the changes before another CI run."; \
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
			$(XARGS) -L1 -I{} $(RM) node_modules/{}; \
		$(NPM) update --no-save --development; \
	}
endif
	$(NPM) list --depth=0 || $(MAKE) deps-npm-unmet-peer


.PHONY: deps-npm-prod
deps-npm-prod:
#	install. 'npm ci' should be more stable and faster if there's a 'package-lock.json'
	$(NPM) install --production
#	remove extraneous dependencies
	$(NPM) prune --production
#	update git dependencies with semver range. 'npm install' doesn't
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


.PHONY: deps-npm-package-lock
deps-npm-package-lock: package-lock.json


package-lock.json: package.json
	$(NPM) install --package-lock-only


.PHONY: check-package-json
check-package-json:
	$(GIT) diff --exit-code package.json || { \
		$(ECHO_ERR) "package.json has changed. Please commit your changes."; \
		exit 1; \
	}


.PHONY: check-package-json-lock
check-package-json-lock:
	if $(GIT_LS) | $(GREP) -q "^package-lock.json$$"; then \
		$(GIT) diff --exit-code package-lock.json || { \
			$(ECHO_ERR) "package-lock.json has changed. Please commit your changes."; \
			exit 1; \
		}; \
		[[ "package-lock.json" -nt "package.json" ]] || { \
			$(ECHO_ERR) "package.json is newer than package-lock.json."; \
			$(ECHO_ERR) "Please run 'make package-lock.json' and commit your changes."; \
			exit 1; \
		}; \
	fi

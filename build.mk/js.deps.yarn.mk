# Adds 'deps-yarn' and 'deps-yarn-prod' internal targets to install all and respectively prod-only npm dependencies.
# The 'deps-yarn' target is automatically included in the 'deps' target via YP_DEPS_TARGETS.
#
# In addition to 'yarn install' functionality, we also:
# * check (and fail) for unmet peer dependencies.
#
# The check for unmet peer dependencies can be silenced on a case-by-case basis
# by commiting a yarn.lock.unmet-peer file that contains the 'peer dep missing' lines
# produced by 'yarn install' that you want to ignore e.g.:
# warning " > lodash-firecloud@0.5.25" has unmet peer dependency "@types/node@>=10"
#
# ------------------------------------------------------------------------------

YARN = $(call which,YARN,yarn)
$(foreach VAR,YARN,$(call make-lazy-once,$(VAR)))

# see https://github.com/yarnpkg/yarn/issues/5869
YARN_CI_OR_INSTALL := install \
	--non-interactive \

ifeq (true,$(CI))
YARN_CI_OR_INSTALL := install \
	--check-files \
	--frozen-lockfile \
	--no-progress \
	--non-interactive \

endif

YP_CLEAN_FILES += \
	node_modules \

YP_DEPS_TARGETS += \
	deps-yarn \

ifdef YP_ECCHECKER_FILES_IGNORE
YP_ECCHECKER_FILES_IGNORE += \
	-e "^yarn.lock$$" \
	-e "^yarn.lock.unmet-peer$$" \

endif

# ------------------------------------------------------------------------------

# yarn only prints unmet peer dependencies on 'yarn install' and 'yarn import',
# and the latter is both faster and requires no network
.PHONY: deps-yarn-unmet-peer
deps-yarn-unmet-peer:
	$(eval YARN_LOCK_TMP := $(shell $(MKTEMP)))
	$(eval YARN_IMPORT_TMP := $(shell $(MKTEMP)))
	$(eval UNMET_PEER_DIFF_TMP := $(shell $(MKTEMP)))
	$(MV) yarn.lock $(YARN_LOCK_TMP)
	$(YARN) import >$(YARN_IMPORT_TMP) 2>&1
	$(DIFF) -U0 \
		<(cat yarn.lock.unmet-peer 2>/dev/null | \
			$(GREP) --only-matching -e "warning \"[^\"]\+\" has unmet peer dependency \"[^\"]\+\"" | \
			$(SORT) -u || true) \
		<(cat $(YARN_IMPORT_TMP) 2>/dev/null | \
			$(GREP) --only-matching -e "warning \"[^\"]\+\" has unmet peer dependency \"[^\"]\+\"" | \
			$(SORT) -u || true) \
		>$(UNMET_PEER_DIFF_TMP) || $(TOUCH) $(UNMET_PEER_DIFF_TMP)
	if $(CAT) $(UNMET_PEER_DIFF_TMP) | $(GREP) -q -e "^\+warning"; then \
		$(ECHO_ERR) "Found new unmet peer dependencies."; \
		$(ECHO_INFO) "If you cannot fix the unmet peer dependencies, and want to ignore them instead,"; \
		$(ECHO_INFO) "please edit yarn.lock.unmet-peer, and append these line(s):"; \
		$(CAT) $(UNMET_PEER_DIFF_TMP) | $(GREP) -e "^\+warning" | $(SED) "s/^\+//g"; \
		$(ECHO); \
	fi
	if $(CAT) $(UNMET_PEER_DIFF_TMP) | $(GREP) -q -e "^\-warning"; then \
		$(ECHO_ERR) "Found outdated unmet peer dependencies."; \
		$(ECHO_INFO) "Please edit yarn.lock.unmet-peer, and remove these line(s):"; \
		$(CAT) $(UNMET_PEER_DIFF_TMP) | $(GREP) -e "^\-warning" | $(SED) "s/^\-//g"; \
		$(ECHO); \
	fi
	$(MV) $(YARN_LOCK_TMP) yarn.lock
	if [[ -s $(UNMET_PEER_DIFF_TMP) ]]; then \
		exit 1; \
	fi


.PHONY: deps-yarn
deps-yarn:
	$(ECHO_INFO) "NODE=$(NODE) $(shell $(NODE) --version)"
	$(ECHO_INFO) "YARN=$(YARN) $(shell $(YARN) --version)"
	$(YARN) config list
	$(ECHO_INFO) "Running 'yarn $(YARN_CI_OR_INSTALL)'."
#	'yarn install' will also remove extraneous dependencies
#	See https://classic.yarnpkg.com/en/docs/cli/prune/
	$(YARN) $(YARN_CI_OR_INSTALL)
ifeq (true,$(CI))
	$(MAKE) deps-yarn-unmet-peer
else
	$(ECHO_SKIP) "deps-yarn-unmet-peer"
endif


.PHONY: deps-yarn-prod
deps-yarn-prod:
	$(ECHO_INFO) "NODE=$(NODE) $(shell $(NODE) --version)"
	$(ECHO_INFO) "YARN=$(YARN) $(shell $(YARN) --version)"
	$(YARN) config list
	$(ECHO_INFO) "Running 'yarn $(YARN_CI_OR_INSTALL)'."
#	'yarn install' will also remove extraneous dependencies
#	See https://classic.yarnpkg.com/en/docs/cli/prune/
	$(YARN)  $(YARN_CI_OR_INSTALL) --production
ifeq (true,$(CI))
	$(MAKE) deps-yarn-unmet-peer
else
	$(ECHO_SKIP) "deps-yarn-unmet-peer"
endif

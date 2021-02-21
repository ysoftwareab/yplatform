# Adds 'deps-yarn' and 'deps-yarn-prod' internal targets to install all and respectively prod-only npm dependencies.
# The 'deps-yarn' target is automatically included in the 'deps' target via SF_DEPS_TARGETS.
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
$(foreach VAR,YARN,$(call make-lazy,$(VAR)))

# see https://github.com/yarnpkg/yarn/issues/5869
YARN_INSTALL_ARGS += \
	--non-interactive \

ifeq ($(CI),true)
YARN_INSTALL_ARGS += \
	--check-files \
	--frozen-lockfile \
	--no-progress \

endif

ifndef NPM_INSTALL_PEER_DEPS_CMD
$(error Please include js.deps.npm.mk, before including js.deps.yarn..mk .)
endif

NPM_INSTALL_PEER_DEPS_CMD := $(YARN) add

SF_CLEAN_FILES += \
	node_modules \

ifndef SF_DEPS_NPM_TARGETS
$(error Please include js.deps.npm.mk, before including js.deps.yarn..mk .)
endif

SF_DEPS_NPM_TARGETS = \

SF_DEPS_NPM_TARGETS += \
	deps-yarn/install \
	deps-npm/update-peer \

ifeq ($(CI),true)
SF_DEPS_NPM_TARGETS += \
	deps-yarn/no-unmet-peer \

endif

SF_DEPS_NPM_TARGETS += \
	deps-npm/sort-deps \

ifdef SF_ECLINT_FILES_IGNORE
SF_ECLINT_FILES_IGNORE += \
	-e "^yarn.lock$$" \
	-e "^yarn.lock.unmet-peer$$" \

endif

# ------------------------------------------------------------------------------

# yarn only prints unmet peer dependencies on 'yarn install' and 'yarn import',
# and the latter is both faster and requires no network
.PHONY: deps-yarn/no-unmet-peer
deps-yarn/no-unmet-peer:
	$(eval YARN_LOCK_TMP := $(shell $(MKTEMP)))
	$(eval YARN_IMPORT_TMP := $(shell $(MKTEMP)))
	$(eval UNMET_PEER_DIFF_TMP := $(shell $(MKTEMP)))
	$(MV) yarn.lock $(YARN_LOCK_TMP)
	$(YARN) import >$(YARN_IMPORT_TMP) 2>&1
	diff -U0 \
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


.PHONY: deps-yarn/install
deps-yarn/install:
#	'yarn install' will also remove extraneous dependencies
#	See https://classic.yarnpkg.com/en/docs/cli/prune/
	$(YARN) install $(YARN_INSTALL_ARGS) $(NPM_PRODUCTION_FLAG)

# Adds a '.git/hooks' internal target that will setup git hooks.
# The '.git/hooks' is automatically added to the 'deps' target via YP_DEPS_TARGETS.
#
# This is based on run-parts as described at
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=719692
#
# ------------------------------------------------------------------------------

GIT_HOOKS_RUN_PARTS := $(wildcard .git-hooks/*.d)
GIT_HOOKS := $(patsubst .git-hooks/%.d,%,$(GIT_HOOKS_RUN_PARTS))

ifneq (,$(GIT_DIR))
ifneq (,$(wildcard .git-hooks))
YP_CLEAN_FILES += \
	$(GIT_DIR)/hooks/yp \
	$(shell [[ ! -f $(GIT_DIR)/hooks/yp ]] || \
		$(CAT) $(GIT_DIR)/hooks/yp | \
		$(SED) "s|^|$(GIT_DIR)/hooks/|") \

YP_DEPS_TARGETS += \
	$(GIT_DIR)/hooks \

endif
endif

# ------------------------------------------------------------------------------

.PHONY: $(GIT_DIR)/hooks
$(GIT_DIR)/hooks:
	$(ECHO_DO) "Installing $(GIT_DIR)/hooks..."
	$(CP_NOSYM) --recursive --no-target-directory .git-hooks/ $@/
	$(TOUCH) $@/yp
	(cd .git-hooks && $(FIND) . -mindepth 1 -print) >> $@/yp
	$(CAT) $@/yp | $(SORT) -u | $(YP_DIR)/bin/sponge $@/yp
	$(ECHO_DONE)


.PHONY: repo/dot.git-hooks/
.git-hooks/%: ## Create a git hook e.g. .git-hooks/pre-push
	$(MKDIR) $@.d
	$(LN) -s ../yplatform/bin/git-hook-run-parts $@
	$(ECHO_INFO) "Created $@ orchestrator."
	$(ECHO_INFO) "Add individual hooks to $@.d ."
	$(ECHO_INFO) "Don't forget to run 'git add .git-hooks; git commit' when done."

# Symlinks '.git/info/exclude' to yplatform 'gitconfig/dot.gitignore_global'
#
# '.git/info/exclude' is automatically added to the 'deps' target via YP_DEPS_TARGETS.
#
# ------------------------------------------------------------------------------

ifneq (,$(GIT_DIR))
YP_DEPS_TARGETS += \
	$(GIT_DIR)/info/exclude \

endif

# ------------------------------------------------------------------------------

.PHONY: $(GIT_DIR)/info/exclude
$(GIT_DIR)/info/exclude: $(YP_DIR)/gitconfig/dot.gitignore_global
	$(MKDIR) $$(dirname $@)
	[[ -f $@ ]] && $(CAT) $@ 2>/dev/null | $(GREP) -v -e "^#" -e "^\s\+$$"| $(GREP) -q "^." || \
			$(LN) -s $< $@

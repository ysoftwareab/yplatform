# Symlinks '.git/info/attributes' to yplatform 'gitconfig/dot.gitattributes_global'.
#
# '.git/info/attributes' is automatically added to the 'deps' target via SF_DEPS_TARGETS.
#
# ------------------------------------------------------------------------------

ifneq (,$(wildcard .git))
SF_DEPS_TARGETS += \
	.git/info/attributes \

endif

# ------------------------------------------------------------------------------

.PHONY: .git/info/attributes
.git/info/attributes: $(SUPPORT_FIRECLOUD_DIR)/gitconfig/dot.gitattributes_global
	$(MKDIR) $$(dirname $@)
	[[ -f $@ ]] && $(CAT) $@ 2>/dev/null | $(GREP) -v -e "^#" -e "^\s\+$$"| $(GREP) -q "^." || \
			$(LN) -sf $< $@

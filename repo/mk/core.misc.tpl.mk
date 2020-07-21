# Adds targets to generate files from "template" files.
# E.g. .vscode/settings.json from .vscode/settings.json.tpl
# where the latter is an executable that outputs the content of the former.
#
# In order to skip some .tpl executables from being called, remove them from SF_TPL_FILES
# SF_TPL_FILES := $(filter-out some/file.json.tpl,$(SF_TPL_FILES)).
#
# You can now add 'some/file.json' or $(SF_TPL_FILES_GEN)
# as a target's dependency or to SF_DEPS_TARGETS.
#
# ------------------------------------------------------------------------------
#
# Adds a 'check-tpl-files' tht will make sure that the generated files are not dirty.
# This is useful as part of a 'git push' with the vanilla pre-push hook,
# which will force a 'git push' to fail if the generated files are not in sync with the template ones
#
# ------------------------------------------------------------------------------

SF_IS_TRANSCRYPTED ?= false

SF_TPL_FILES_IGNORE += \
	-e "^$$" \
	$(SF_VENDOR_FILES_IGNORE) \

SF_TPL_FILES += $(shell $(GIT_LS) . | \
	$(GREP) -e "\\.tpl$$" | \
	$(GREP) -Fvxf <($(SF_IS_TRANSCRYPTED) || [[ ! -x $(GIT_ROOT)/transcrypt ]] || $(GIT_ROOT)/transcrypt -l) | \
	$(GREP) -Fvxf <($(GIT) config --file .gitmodules --get-regexp path | $(CUT) -d' ' -f2 || true) | \
	$(GREP) -v $(SF_TPL_FILES_IGNORE) | \
	$(SED) "s/^/'/g" | \
	$(SED) "s/$$/'/g")

# TODO maybe remove the SED above instead?!
SF_TPL_FILES_MAKE = $(patsubst '%',%,$(SF_TPL_FILES))
SF_TPL_FILES_MAKE_GEN = $(patsubst %.tpl,%,$(SF_TPL_FILES_MAKE))

SF_CHECK_TARGETS += \
	check-tpl-files \

# ------------------------------------------------------------------------------

$(SF_TPL_FILES_MAKE_GEN): %: %.tpl
#	NOTE A file pattern can be added to SF_TPL_FILES_IGNORE
#	after the line above is expanded (when this file is parsed).
	if $$($(ECHO) "$<" | $(GREP) -q -v $(SF_TPL_FILES_IGNORE)); then \
		$(ECHO_DO) "Generating $@ from template $<..."; \
		$< > $@; \
		$(ECHO_DONE); \
	fi


.PHONY: check-tpl-files
check-tpl-files:
	$(MAKE) $(SF_TPL_FILES_MAKE_GEN)
	$(GIT) diff --exit-code $(SF_TPL_FILES_MAKE) $(SF_TPL_FILES_MAKE_GEN) || { \
		$(ECHO_ERR) "Some templates or generated files have uncommitted changes."; \
		exit 1; \
	}

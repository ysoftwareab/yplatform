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

SF_IS_TRANSCRYPTED ?= false

SF_TPL_FILES_IGNORE += \
	-e "^$$" \
	$(SF_VENDOR_FILES_IGNORE) \

SF_TPL_FILES += $(shell $(GIT_LS) . | \
	$(GREP) -e "\\.tpl$$" | \
	$(GREP) -Fvxf <($(SF_IS_TRANSCRYPTED) || [[ ! -x $(GIT_ROOT)/transcrypt ]] || $(GIT_ROOT)/transcrypt -l) | \
	$(GREP) -Fvxf <($(GIT) config --file .gitmodules --get-regexp path | $(CUT) -d' ' -f2 || true) | \
	$(GREP) -v $(SF_JSONLINT_FILES_IGNORE) | \
	$(SED) "s/^/'/g" | \
	$(SED) "s/$$/'/g")

SF_TPL_FILES_GEN = $(patsubst %.tpl,%,$(SF_TPL_FILES))

# ------------------------------------------------------------------------------

.PHONY: $(SF_TPL_FILES_GEN)
$(SF_TPL_FILES_GEN): %: %.tpl
#	NOTE A file pattern can be added to SF_TPL_FILES_IGNORE
#	after the line above is expanded (when this file is parsed.
	if $$($(ECHO) "$(SF_TPL_FILES)" | $(GREP) -q -v $(SF_TPL_FILES_IGNORE)); then \
		$(ECHO_DO) "Generating $@ from template $<..."; \
		$< > $@; \
		$(ECHO_DONE); \
	fi

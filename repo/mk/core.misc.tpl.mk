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

SF_TPL_FILES := $(shell $(FIND_Q_NOSYM) . -type f -executable -name "*.tpl" -print)

SF_TPL_FILES_GEN = $(patsubst %.tpl,%,$(SF_TPL_FILES))

# ------------------------------------------------------------------------------

.PHONY: $(SF_TPL_FILES_GEN)
$(SF_TPL_FILES_GEN): %: %.tpl
	if $$($(ECHO) "$(SF_TPL_FILES)" | $(GREP) -q "$<"); then \
		$(ECHO_INFO) "$< was removed from SF_TPL_FILES."; \
		$(ECHO_SKIP) "Generating $@ from template $<..."; \
	else \
		$(ECHO_DO) "Generating $@ from template $<..."; \
		$< > $@; \
		$(ECHO_DONE); \
	fi

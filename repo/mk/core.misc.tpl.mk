# Adds targets to generate files from "template" files.
# E.g. .vscode/settings.json from .vscode/settings.json.tpl
# where the latter is an executable that outputs the content of the former.
#
# In order to generate a file from its template, add it SF_TPL_FILES.
# SF_TPL_FILES += \
#	some.file.tpl \
#
# You can now add 'some.file' as a target's dependency.
#
# ------------------------------------------------------------------------------

SF_TPL_FILES += \

SF_TPL_FILES_GEN = $(patsubst %.tpl,%,$(SF_TPL_FILES))

# ------------------------------------------------------------------------------

.PHONY: $(SF_TPL_FILES_GEN)
$(SF_TPL_FILES_GEN): $(SF_TPL_FILES): %: %.tpl:
	$< > $@

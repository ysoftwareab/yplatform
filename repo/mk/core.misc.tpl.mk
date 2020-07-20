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

SF_TPL_FILES_GEN = $(patsubst %.tpl,%,$(SF_TPL_FILES))

SF_CHECK_TARGETS += \
	check-tpl-files \

# ------------------------------------------------------------------------------

.PHONY: $(SF_TPL_FILES_GEN)
$(SF_TPL_FILES_GEN): %: %.tpl
#	NOTE A file pattern can be added to SF_TPL_FILES_IGNORE
#	after the line above is expanded (when this file is parsed).
	if $$($(ECHO) "$<" | $(GREP) -q -v $(SF_TPL_FILES_IGNORE)); then \
		$(ECHO_DO) "Generating $@ from template $<..."; \
		$< > $@; \
		$(ECHO_DONE); \
	fi


.PHONY: check-tpl-files
check-tpl-files:
	for SF_TPL_FILE in $(SF_TPL_FILES); do \
		$(GIT) diff --exit-code $${SF_TPL_FILE} || { \
			$(ECHO_ERR) "$${SF_TPL_FILE} has uncommitted changes."; \
			exit 1; \
		}; \
		SF_TPL_FILE_TIME="$$($(GIT) log --pretty=format:%cd -n 1 --date=iso -- "$${SF_TPL_FILE}")"; \
    SF_TPL_FILE_TIME="$$($(DATE) -j -f "%Y-%m-%d %H:%M:%S %z" "$${SF_TPL_FILE_TIME}" "+%s")"; \
		SF_TPL_FILE_GEN_TIME="$$($(GIT) log --pretty=format:%cd -n 1 --date=iso -- "$${SF_TPL_FILE%.tpl}")"; \
    SF_TPL_FILE_GEN_TIME="$$($(DATE) -j -f "%Y-%m-%d %H:%M:%S %z" "$${SF_TPL_FILE_GEN_TIME}" "+%s")"; \
		[[ "$${SF_TPL_FILE_TIME}" -gt "$${SF_TPL_FILE_GEN_TIME}" ]] || { \
			$(ECHO_ERR) "$${SF_TPL_FILE} has changes newer than $${SF_TPL_FILE%.tpl}."; \
			exit 1; \
		} \
	done

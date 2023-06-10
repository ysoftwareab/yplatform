# Add a 'yp-generate-from-template' function to generate files from "template" files.
# E.g. .vscode/settings.json from .vscode/settings.json.tpl
# where the latter is an executable that outputs the content of the former.
#
# YP_CHECK_TPL_FILES += some/file.json.tpl
#
# some/file.json: some/file.json.tpl; $(call yp-generate-from-template)
#
# You can now add 'some/file.json' or the entire $(YP_CHECK_TPL_FILES)
# as an individual target's dependency, or as an additional entry to YP_DEPS_TARGETS.
#
# ------------------------------------------------------------------------------
#
# Adds a 'check-tpl-files' that will make sure that the generated files are not dirty.
# The 'check-tpl-files' target is automatically added to the 'check' target via YP_CHECK_TARGETS.
#
# This is useful as part of a 'git push' with the vanilla pre-push hook,
# which will force a 'git push' to fail if the generated files are not in sync with the template ones.
#
# ------------------------------------------------------------------------------

YP_CHECK_TPL_FILES += \

define yp-generate-from-template
	$(ECHO_DO) "Generating $@ from template $<..."
	$(shell $(REALPATH) -s $<) > $@
	$(ECHO_DONE)
endef
PRINTVARS_VARIABLES_IGNORE += yp-generate-from-template

define yp-generate-from-template-patch # patch: original patched
	$(ECHO_DO) "Generating $@ from original $< and patched $1..."
	# $(DIFF) -u original patched > patch
	$(DIFF) -u --label $< --label $1 $< $1 > $@ || true
	$(ECHO_DONE)
endef
PRINTVARS_VARIABLES_IGNORE += yp-generate-from-template-patch

define yp-generate-from-template-patched # patched: original patch
	$(ECHO_DO) "Generating $@ from original $< and patch $1..."
	# $(CAT) patch | $(PATCH_STDOUT) original > patched
	$(CAT) $1 | $(PATCH) $< -o $@
	$(ECHO_DONE)
endef
PRINTVARS_VARIABLES_IGNORE += yp-generate-from-template-patched

YP_CHECK_TARGETS += \
	check-tpl-files \

# ------------------------------------------------------------------------------

#	.vscode/settings.json: .vscode/settings.json.tpl
#		$(call generate-from-template,$<,$@)


.PHONY: check-tpl-files
check-tpl-files:
	YP_CHECK_TPL_FILES_TMP=($(YP_CHECK_TPL_FILES)); \
	[[ "$${#YP_CHECK_TPL_FILES_TMP[@]}" = "0" ]] || { \
		$(MAKE) --no-print-directory $${YP_CHECK_TPL_FILES_TMP[@]}; \
		$(GIT) diff --exit-code $${YP_CHECK_TPL_FILES_TMP[@]} || { \
			$(ECHO_ERR) "Some template-generated files have uncommitted changes."; \
			exit 1; \
		} \
	}

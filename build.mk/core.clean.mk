# Adds a 'clean' target that will remove all YP_CLEAN_FILES.
# This is a so-called safe target that removes only defined files,
# leaving untouched files that are unknown to the repository.
#
# ------------------------------------------------------------------------------
#
# Adds a 'nuke' target that will remove all untracked files,
# and reset all the changes to tracked files.
# This is an unsafe target and is meant as an alternative to removing and cloning
# the repository from scratch, when the 'clean' target fails to fix unforeseen issues.
#
# To add another file/folder to the list of files to clean do
# YP_CLEAN_FILES += \
#	clean/some/other/path \
#
# ------------------------------------------------------------------------------

YP_CLEAN_FILES += \
	Makefile.lazy \
	.env.mk \
	.bin-yp-env.mk \

# ------------------------------------------------------------------------------

.PHONY: clean
clean: ## Clean.
	[[ "$(words $(YP_CLEAN_FILES))" = "0" ]] || { \
		$(ECHO_DO) "Cleaning..."; \
		$(RM) $(YP_CLEAN_FILES); \
		$(ECHO_DONE); \
	}


.PHONY: nuke
nuke: ## Nuke all files/changes not checked in.
	! $(GIT_REPO_HAS_CHANGED_FILES) || { \
		$(ECHO); \
		$(ECHO) "       Your repository has deleted/modified/new files,"; \
		$(ECHO) "       and continuing will remove/reset those files."; \
		$(GIT) status --porcelain | $(SED) "s/^/       /g"; \
		$(ECHO) "[Q   ] Continue?"; \
		$(ECHO) "       Press ENTER to Continue."; \
		$(ECHO) "       Press Ctrl+C to Cancel."; \
		read -r -p "" -n1; \
	}
	$(ECHO_DO) "Nuking..."
	$(GIT) reset -- .
	$(GIT) submodule foreach --recursive "$(GIT) reset -- ."
	$(GIT) checkout HEAD -- .

	$(GIT) clean -xdf -- .
	$(GIT) submodule foreach --recursive "$(GIT) checkout HEAD -- ."
	$(GIT) submodule foreach --recursive "$(GIT) clean -xdf -- ."
	$(ECHO_DONE)


.PHONY: clobber
clobber: nuke
	:

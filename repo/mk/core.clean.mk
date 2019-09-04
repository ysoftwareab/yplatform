# Adds a 'clean' target that will remove all SF_CLEAN_FILES.
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
# SF_CLEAN_FILES := \
#	$(SF_CLEAN_FILES) \
#	clean/some/other/path \
#
# ------------------------------------------------------------------------------

SF_CLEAN_FILES := \

# ------------------------------------------------------------------------------

.PHONY: clean
clean: ## Clean.
	[[ "$(words $(SF_CLEAN_FILES))" = "0" ]] || { \
		$(ECHO_DO) "Cleaning..."; \
		$(RM) $(SF_CLEAN_FILES); \
		$(ECHO_DONE); \
	}


.PHONY: nuke
nuke: ## Nuke all files/changes not checked in.
	[[ ! $(GIT_REPO_HAS_CHANGED_FILES) ]] || { \
		$(ECHO); \
		$(ECHO) "       Your repository has deleted/modified/new files,"; \
		$(ECHO) "       and continuing will remove/reset those files."; \
		$(ECHO) "[Q   ] Continue?"; \
		$(ECHO) "       Press ENTER to Continue."; \
		$(ECHO) "       Press Ctrl+C to Cancel."; \
		read -p ""; \
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

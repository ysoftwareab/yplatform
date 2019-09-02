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

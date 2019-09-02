# Adds a 'snapshot' target that will create
# a SF_SNAPSHOT_ZIP (defaults to snapshot.zip) file
# with all the untracked files in the current repository.
#
# For convenience, specific files can be ignored
# via grep arguments given to SF_SNAPSHOT_FILES_IGNORE:
# SF_SNAPSHOT_FILES_IGNORE := \
#	$(SF_SNAPSHOT_FILES_IGNORE) \
#	-e "^path/to/dir/" \
#	-e "^path/to/file$" \
#
# ------------------------------------------------------------------------------
#
# Adds a 'reset-to-snapshot' target that will restore the current repository
# to the contents of the SF_SNAPSHOT_ZIP file.
#
# ------------------------------------------------------------------------------

SF_SNAPSHOT_DIR := snapshot.dir
SF_SNAPSHOT_ZIP := snapshot.zip
SF_SNAPSHOT_GIT_HASH := .git_hash

SF_SNAPSHOT_FILES_IGNORE = \
	-e "^$(SF_SNAPSHOT_DIR)/" \
	-e "^$(SF_SNAPSHOT_ZIP)$$" \

# ------------------------------------------------------------------------------

.PHONY: snapshot
snapshot: ## Create a zip snapshot of all the git content that is not tracked.
	@$(ECHO_DO) "Creating $(SF_SNAPSHOT_ZIP)..."
	$(RM) $(SF_SNAPSHOT_ZIP)
	$(RM) $(SF_SNAPSHOT_DIR)
	$(MKDIR) $(SF_SNAPSHOT_DIR)
	for f in `$(GIT_LS_SUB)` `$(GIT_LS_NEW) | $(GREP) -v $(SF_SNAPSHOT_FILES_IGNORE)`; do \
		$(CP) --parents $${f} $(SF_SNAPSHOT_DIR)/; \
	done
	$(ECHO) -n "$(GIT_HASH)" > $(SF_SNAPSHOT_DIR)/$(SF_SNAPSHOT_GIT_HASH)
	cd $(SF_SNAPSHOT_DIR) && \
		$(ZIP) -q $(GIT_ROOT)/$(SF_SNAPSHOT_ZIP) $$($(FIND_Q) . -mindepth 1 -maxdepth 1 -printf '%P\n')
	@$(ECHO_DONE)


.PHONY: reset-to-snapshot
reset-to-snapshot: ## Reset codebase to the contents of the zip snapshot.
	@$(ECHO_DO) "Resetting to $(SF_SNAPSHOT_ZIP)..."
	$(UNZIP) $(SF_SNAPSHOT_ZIP) $(SF_SNAPSHOT_GIT_HASH)
	$(GIT) reset --hard `$(CAT) ${SF_SNAPSHOT_GIT_HASH}`
	$(GIT) reset --soft $(GIT_HASH_SHORT)
	$(GIT) clean -xdf -e $(SF_SNAPSHOT_ZIP) -- .
	$(GIT) reset
	$(UNZIP) -q snapshot.zip
	@$(ECHO_DONE)

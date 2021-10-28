# Adds a 'snapshot' internal target that will create
# a YP_SNAPSHOT_ZIP (defaults to snapshot.zip) file
# with all the untracked files in the current repository.
#
# For convenience, specific files can be ignored
# via grep arguments given to YP_SNAPSHOT_FILES_IGNORE:
# YP_SNAPSHOT_FILES_IGNORE += \
#	-e "^path/to/dir/" \
#	-e "^path/to/file$" \
#
# ------------------------------------------------------------------------------
#
# Adds a 'reset-to-snapshot' internal target that will restore
# the current repository to the contents of the YP_SNAPSHOT_ZIP file.
#
# ------------------------------------------------------------------------------

YP_SNAPSHOT_DIR := snapshot.dir
YP_SNAPSHOT_ZIP := snapshot.zip
YP_SNAPSHOT_GIT_HASH := .git_hash

YP_SNAPSHOT_FILES_IGNORE += \
	-e "^$(YP_SNAPSHOT_DIR)/" \
	-e "^$(YP_SNAPSHOT_ZIP)$$" \

# ------------------------------------------------------------------------------

.PHONY: snapshot
snapshot:
	@$(ECHO_DO) "Creating $(YP_SNAPSHOT_ZIP)..."
	$(RM) $(YP_SNAPSHOT_ZIP)
	$(RM) $(YP_SNAPSHOT_DIR)
	$(MKDIR) $(YP_SNAPSHOT_DIR)
	for f in $$($(GIT_LS_SUB)) $$($(GIT_LS_NEW) | $(GREP) -v $(YP_SNAPSHOT_FILES_IGNORE)); do \
		$(CP) --parents $${f} $(YP_SNAPSHOT_DIR)/; \
	done
	$(ECHO) -n "$(GIT_HASH)" > $(YP_SNAPSHOT_DIR)/$(YP_SNAPSHOT_GIT_HASH)
	cd $(YP_SNAPSHOT_DIR) && \
		$(ZIP) -q $(GIT_ROOT)/$(YP_SNAPSHOT_ZIP) $$($(FIND_Q) . -mindepth 1 -maxdepth 1 -printf '%P\n')
	@$(ECHO_DONE)


.PHONY: reset-to-snapshot
reset-to-snapshot:
	@$(ECHO_DO) "Resetting to $(YP_SNAPSHOT_ZIP)..."
	$(UNZIP) $(YP_SNAPSHOT_ZIP) $(YP_SNAPSHOT_GIT_HASH)
	$(GIT) reset --hard $$($(CAT) ${YP_SNAPSHOT_GIT_HASH})
	$(GIT) reset --soft $(GIT_HASH_SHORT)
	$(GIT) clean -xdf -e $(YP_SNAPSHOT_ZIP) -- .
	$(GIT) reset
	$(UNZIP) -q snapshot.zip
	@$(ECHO_DONE)

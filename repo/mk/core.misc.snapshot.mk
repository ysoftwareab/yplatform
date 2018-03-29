SNAPSHOT_DIR := snapshot.dir
SNAPSHOT_ZIP := snapshot.zip
SNAPSHOT_GIT_HASH := .git_hash

SNAPSHOT_FILES_IGNORE = \
	-e "^$(SNAPSHOT_DIR)/" \
	-e "^$(SNAPSHOT_ZIP)$$" \

# ------------------------------------------------------------------------------

.PHONY: snapshot
snapshot: ## Create a zip snapshot of all the git content that is not tracked.
	@$(ECHO_DO) "Creating $(SNAPSHOT_ZIP)..."
	$(RM) $(SNAPSHOT_DIR)
	$(MKDIR) $(SNAPSHOT_DIR)
	# for f in `$(GIT_LS_SUB)` `$(GIT_LS_NEW) | $(GREP) -v $(SNAPSHOT_FILES_IGNORE)`; do \
	# first copying, then ignoring=deleting because of for-loop limits
	for f in `$(GIT_LS_SUB)` `$(GIT_LS_NEW)`; do \
		$(CP) --parents $${f} $(SNAPSHOT_DIR)/; \
	done
	cd $(SNAPSHOT_DIR) && { \
		$(RM) $(SNAPSHOT_DIR).ignore; \
		$(FIND_Q) . -type f | \
			$(SED) "s|^\./||g" | \
			$(GREP) $(SNAPSHOT_FILES_IGNORE) > $(SNAPSHOT_DIR).ignore || \
				$(RM) $(SNAPSHOT_DIR).ignore; \
		[ ! -f $(SNAPSHOT_DIR).ignore ] || $(CAT) $(SNAPSHOT_DIR).ignore | $(XARGS) $(RM); \
		$(RM) $(SNAPSHOT_DIR).ignore; \
	}
	$(ECHO) -n "$(GIT_HASH)" > $(SNAPSHOT_DIR)/$(SNAPSHOT_GIT_HASH)
	cd $(SNAPSHOT_DIR) && $(ZIP) -q $(GIT_ROOT)/$(SNAPSHOT_ZIP) * .*
	@$(ECHO_DONE)


.PHONY: reset-to-snapshot
reset-to-snapshot: ## Reset codebase to the contents of the zip snapshot.
	@$(ECHO_DO) "Resetting to $(SNAPSHOT_ZIP)..."
	$(UNZIP) $(SNAPSHOT_ZIP) $(SNAPSHOT_GIT_HASH)
	$(GIT) reset --hard `$(CAT) ${SNAPSHOT_GIT_HASH}`
	$(GIT) reset --soft $(GIT_HASH_SHORT)
	$(GIT) clean -xdf -e $(SNAPSHOT_ZIP) -- .
	$(GIT) reset
	$(UNZIP) -q snapshot.zip
	@$(ECHO_DONE)

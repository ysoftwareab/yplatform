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
	$(RM) $(SF_SNAPSHOT_DIR)
	$(MKDIR) $(SF_SNAPSHOT_DIR)
	# for f in `$(GIT_LS_SUB)` `$(GIT_LS_NEW) | $(GREP) -v $(SF_SNAPSHOT_FILES_IGNORE)`; do \
	# first copying, then ignoring=deleting because of for-loop limits
	for f in `$(GIT_LS_SUB)` `$(GIT_LS_NEW)`; do \
		$(CP) --parents $${f} $(SF_SNAPSHOT_DIR)/; \
	done
	cd $(SF_SNAPSHOT_DIR) && { \
		$(RM) $(SF_SNAPSHOT_DIR).ignore; \
		$(FIND_Q) . -type f | \
			$(SED) "s|^\./||g" | \
			$(GREP) $(SF_SNAPSHOT_FILES_IGNORE) > $(SF_SNAPSHOT_DIR).ignore || \
				$(RM) $(SF_SNAPSHOT_DIR).ignore; \
		[ ! -f $(SF_SNAPSHOT_DIR).ignore ] || $(CAT) $(SF_SNAPSHOT_DIR).ignore | $(XARGS) -L1 $(RM); \
		$(RM) $(SF_SNAPSHOT_DIR).ignore; \
	}
	$(ECHO) -n "$(GIT_HASH)" > $(SF_SNAPSHOT_DIR)/$(SF_SNAPSHOT_GIT_HASH)
	cd $(SF_SNAPSHOT_DIR) && $(ZIP) -q $(GIT_ROOT)/$(SF_SNAPSHOT_ZIP) * .*
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

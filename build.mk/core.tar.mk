# Adds a 'tar' target that will build a zipball of the current git worktree.
#
# ------------------------------------------------------------------------------
#
# Adds a 'tar/%' target that will build a archive of given format of the current git worktree.
# Format can be whatever git-archive supports.
#
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------

.PHONY: tar
# NOTE: we default to zip (instead of tar, git-archive's default)
tar: tar/zip ## Archive source files as a zip file.


.PHONY: tar/%
# NOTE: below is a workaround for 'make help' to work
tar/tar: ## Archive source files as a tar file.
tar/tgz: ## Archive source files as a tgz file.
tar/tar.gz: ## Archive source files as a tar.gz file.
tar/zip: ## Archive source files as a zip file.
tar/%:
	$(eval SF_TARBALL_FORMAT := $*)
	if [[ -n "$(GIT_TAGS)" ]]; then \
		SF_TARBALL=archive-$(shell $(GIT) tag -l --points-at HEAD | $(HEAD) -1); \
	elif [[ -n "$(GIT_BRANCH)" ]]; then \
		SF_TARBALL=archive-$(GIT_BRANCH)-$(GIT_HASH); \
	else \
		SF_TARBALL=archive-$(GIT_HASH); \
	fi; \
	$(ECHO_DO) "Archiving into $${SF_TARBALL}..."; \
	$(SUPPORT_FIRECLOUD_DIR)/bin/git-archive-all \
		--format=$(SF_TARBALL_FORMAT) \
		-o $${SF_TARBALL}.$(SF_TARBALL_FORMAT) HEAD; \
	$(ECHO_DONE)

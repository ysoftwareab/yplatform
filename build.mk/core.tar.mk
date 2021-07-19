# Adds a 'tar' target that will build a tarball of the current git worktree.
#
# ------------------------------------------------------------------------------
#
# Adds a 'tar/%' target that will build a archive of given format of the current git worktree.
# Format can be whatever git-archive supports.
#
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------

.PHONY: tar
tar: tar/tar.gz ## Create a tar file of the source files.


.PHONY: tar/%
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
	$(GIT) archive --format=$(SF_TARBALL_FORMAT) -o $${SF_TARBALL}.$(SF_TARBALL_FORMAT) HEAD; \
	$(ECHO_DONE)

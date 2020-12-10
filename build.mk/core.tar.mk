# Adds a 'tar' target that will build a tarball of the current git worktree.
#
# ------------------------------------------------------------------------------
#
# Adds a 'tar/%' target that will build a archive of given format of the current git worktree.
# Format can be whatever git-archive supports.
#
# ------------------------------------------------------------------------------

SF_TARBALL := archive-$(GIT_HASH)
ifneq ($(GIT_TAGS),)
SF_TARBALL := archive-$(shell $(GIT) tag -l --points-at HEAD | $(HEAD) -1)
else
ifneq ($(GIT_BRANCH),)
SF_TARBALL := archive-$(GIT_BRANCH)-$(GIT_HASH)
endif
endif

# ------------------------------------------------------------------------------

.PHONY: tar
tar: tar/tar.gz ## Create a tar file of the source files.


.PHONY: tar/%
tar/%:
	$(eval SF_TARBALL_FORMAT := $*)
	$(ECHO_DO) "Archiving into $(SF_TARBALL)..."
	$(GIT) archive --format=$(SF_TARBALL_FORMAT) -o $(SF_TARBALL).$(SF_TARBALL_FORMAT) HEAD
	$(ECHO_DONE)

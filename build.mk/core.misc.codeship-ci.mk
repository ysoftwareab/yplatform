# Adds a 'jet-steps' target to start 'jet steps' with proper configuration.
#
# ------------------------------------------------------------------------------

JET = $(call which,JET,jet)
$(foreach VAR,JET,$(call make-lazy-once,$(VAR)))

# ------------------------------------------------------------------------------

.PHONY: jet-steps
jet-steps:
	$(JET) steps \
		--env CI=true \
		--env CI_NAME=codeship \
		--ci-branch $(GIT_BRANCH) \
		--ci-build-id 0 \
		--ci-commit-description $(GIT_DESCRIBE) \
		--ci-commit-id $(GIT_HASH) \
		--ci-commit-message "$$($(GIT) log -1 --format=%s $(GIT_HASH))" \
		--ci-committer-email "$$($(GIT) log -1 --format=%ce $(GIT_HASH))" \
		--ci-committer-name "$$($(GIT) log -1 --format=%cn $(GIT_HASH))" \
		--ci-repo-name "$$($(GIT) remote -v 2>/dev/null | \
		$(GREP) -oP "(?<=github.com.).\{1,\}" | \
		$(GREP) -oP ".\{1,\}(?= \(fetch\))" | \
		$(HEAD) -n1 | \
		$(SED) "s/\.git$$//")" \

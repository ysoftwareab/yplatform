# Adds a 'ci/<BRANCH>' target that will force push HEAD to the BRANCH,
# triggering a CI build on a specific CI platform.
#
# ------------------------------------------------------------------------------
#
# Adds a 'debug-ci/<BRANCH>' target that will force push a '[debug ci]' commit to the BRANCH,
# triggering a CI build on a specific CI platform, and start a debug session.
#
# ------------------------------------------------------------------------------

CI_PREFIX += \
	appveyor \
	circleci \
	cirrus \
	codeship \
	github \
	gitlab \
	semaphore \
	travis \

CI_TARGETS += \
	$(patsubst %,ci/%-\%,$(CI_PREFIX)) \

DEBUG_CI_TARGETS += \
	$(patsubst %,debug-ci/%-\%,$(CI_PREFIX)) \

# ------------------------------------------------------------------------------

.PHONY: $(CI_TARGETS)
# NOTE: below is a workaround for 'make help-all' to work
ci/appveyor-%:
ci/circleci-%:
ci/cirrus-%:
ci/codeship-%:
ci/github-%:
ci/gitlab-%:
ci/semaphore-%:
ci/travis-%:
$(CI_TARGETS):
ci/%: ## Force push to a CI branch.
	$(eval BRANCH := $(@:ci/%=%))
	$(GIT) push --force --no-verify $(GIT_REMOTE_OR_ORIGIN) head:refs/heads/$(BRANCH)

.PHONY: $(DEBUG_CI_TARGETS)
# NOTE: below is a workaround for 'make help-all' to work
debug-ci/appveyor-%:
debug-ci/circleci-%:
debug-ci/cirrus-%:
debug-ci/codeship-%:
debug-ci/github-%:
debug-ci/gitlab-%:
debug-ci/semaphore-%:
debug-ci/travis-%:
$(DEBUG_CI_TARGETS):
debug-ci/%: ## Force push to a CI branch and debug (tmate session).
	$(eval BRANCH := $(@:debug-ci/%=%))
	echo "$(GIT_COMMIT_MSG)" | $(GREP) -q "\[debug ci\]" || \
		$(GIT) commit --allow-empty -m "$(GIT_COMMIT_MSG) [debug ci]"
	$(GIT) push --force --no-verify $(GIT_REMOTE_OR_ORIG_IN) head:refs/heads/$(BRANCH)

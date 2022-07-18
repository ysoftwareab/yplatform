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
	bitrise \
	buddy \
	circle \
	cirrus \
	codeship \
	drone \
	github \
	gitlab \
	semaphore \
	sourcehut \
	travis \

CI_TARGETS += \
	$(patsubst %,ci/%-\%,$(CI_PREFIX)) \

DEBUG_CI_TARGETS += \
	$(patsubst %,debug-ci/%-\%,$(CI_PREFIX)) \

DEBUG_BOOTSTRAP_TARGETS += \
	$(patsubst %,debug-bootstrap/%-\%,$(CI_PREFIX)) \

# ------------------------------------------------------------------------------

.PHONY: $(CI_TARGETS)
# NOTE: below is a workaround for 'make help-all' to work
ci/appveyor-%:
ci/bitrise-%:
ci/buddy-%:
ci/circle-%:
ci/cirrus-%:
ci/codeship-%:
ci/drone-%:
ci/github-%:
ci/gitlab-%:
ci/semaphore-%:
ci/sourcehut-%:
ci/travis-%:
$(CI_TARGETS):
ci/%: ## Force push to a CI branch.
	$(eval BRANCH := $(@:ci/%=%))
	$(GIT) push --force --no-verify $(GIT_REMOTE_OR_ORIGIN) head:refs/heads/$(BRANCH)

.PHONY: $(DEBUG_CI_TARGETS)
# NOTE: below is a workaround for 'make help-all' to work
debug-ci/appveyor-%:
debug-ci/bitrise:
debug-ci/buddy:
debug-ci/circle-%:
debug-ci/cirrus-%:
debug-ci/codeship-%:
debug-ci/drone-%:
debug-ci/github-%:
debug-ci/gitlab-%:
debug-ci/semaphore-%:
debug-ci/sourcehut-%:
debug-ci/travis-%:
$(DEBUG_CI_TARGETS):
debug-ci/%: ## Force push to a CI branch and debug post-ci-bootstrap (tmate session).
	$(eval BRANCH := $(@:debug-ci/%=%))
	$(ECHO) "$(GIT_COMMIT_MSG)" | $(GREP) -q "\[debug ci\]" || \
		$(GIT) commit --allow-empty -m "$(GIT_COMMIT_MSG) [debug ci]"
	$(GIT) push --force --no-verify $(GIT_REMOTE_OR_ORIGIN) head:refs/heads/$(BRANCH)

.PHONY: $(DEBUG_BOOTSTRAP_TARGETS)
# NOTE: below is a workaround for 'make help-all' to work
debug-bootstrap/appveyor-%:
debug-bootstrap/bitrise:
debug-bootstrap/buddy:
debug-bootstrap/bootstraprcle-%:
debug-bootstrap/bootstraprrus-%:
debug-bootstrap/codeship-%:
debug-bootstrap/drone-%:
debug-bootstrap/github-%:
debug-bootstrap/gitlab-%:
debug-bootstrap/semaphore-%:
debug-bootstrap/sourcehut-%:
debug-bootstrap/travis-%:
$(DEBUG_BOOTSTRAP_TARGETS):
debug-bootstrap/%: ## Force push to a CI branch and debug pre-bootstrap (tmate session).
	$(eval BRANCH := $(@:debug-bootstrap/%=%))
	$(ECHO) "$(GIT_COMMIT_MSG)" | $(GREP) -q "\[debug bootstrap\]" || \
		$(GIT) commit --allow-empty -m "$(GIT_COMMIT_MSG) [debug bootstrap]"
	$(GIT) push --force --no-verify $(GIT_REMOTE_OR_ORIGIN) head:refs/heads/$(BRANCH)

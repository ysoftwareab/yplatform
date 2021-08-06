# Adds a 'ci/<BRANCH>' target that will force push HEAD to the BRANCH,
# triggering a CI build on a specific CI platform.
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

# ------------------------------------------------------------------------------

.PHONY: $(CI_TARGETS)
# NOTE: below is a workaround for 'make help-all' to work
ci/appveyor-%:
ci/circleci-%:
ci/cirrus:
ci/codeship-%:
ci/github:
ci/gitlab-%:
ci/semaphore-%:
ci/travis-%:
$(CI_TARGETS):
ci/%: ## Force push to a CI branch.
	$(eval BRANCH := $(@:ci/%=%))
	$(GIT) push --force --no-verify $(GIT_REMOTE) head:refs/heads/$(BRANCH)

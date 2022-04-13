# This is a collection of "must have" targets for repositories with "environments",
# like "cloud" apps.
#
# The convention states that such a repository can have multiple live environments,
# all driven by the "env/<name>" branches.
#
# Promoting a tag to such a branch should be followed by the CI picking up the push,
# and deploying that tag's artifacts to the respective named environment.
#
# ------------------------------------------------------------------------------

# NOTE might be enough with core.common.mk
ifndef YP_GENERIC_COMMON_INCLUDES_DEFAULT
$(error Please include generic.common.mk, before including env.common.mk)
endif

include $(YP_DIR)/build.mk/env.promote.mk
include $(YP_DIR)/build.mk/env.teardown.mk

# ------------------------------------------------------------------------------

YP_PROMOTE_ENVS += \
	dev \
	prod-staging \
	prod \


# ------------------------------------------------------------------------------

.PHONY: envs
envs: ## View the status of env branches.
	$(eval YP_PROMOTE_ENVS_REMOTE_REFS := $(patsubst %,refs/heads/$(GIT_REMOTE)/env/%,$(SF_PROMOTE_ENVS)))
	$(eval OLDEST_ENV := $(shell \
		$(GIT) fetch 2>/dev/null >&2; \
		$(GIT) for-each-ref --format="%(committerdate:unix) %(refname:short)" $(YP_PROMOTE_ENVS_REMOTE_REFS) | \
		$(SORT) -k1 | \
		$(HEAD) -n1 | \
		$(CUT) -d" " -f2))
	$(ECHO)
	$(ECHO_INFO) "Commits since oldest env:"
	$(ECHO)
	$(GIT) --no-pager log \
		--color \
		--graph \
		--date=short \
		--pretty=format:"%h %ad %s" \
		--no-decorate \
		$(GIT_REMOTE)/$(OLDEST_ENV).. | \
		$(GREP) --color -i -E "^|break" || true

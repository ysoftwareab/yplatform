SF_PROMOTE_ENVS := \
	dev \
	prod-staging \
	prod \

# ------------------------------------------------------------------------------

.PHONY: promote/%
promote/%: ## promote/<env>/<tag> Promote tag to env branch.
	$(eval ENV_NAME := $(shell dirname "$*"))
	$(eval TAG := $(shell basename "$*"))
	$(ECHO) "$(SF_PROMOTE_ENVS)" | $(GREP) -q -e "$(ENV_NAME)" || { \
		$(ECHO_ERR) "$(ENV_NAME) is not a known env."; \
		exit 1; \
	}
	$(GIT) tag --list | $(GREP) -q "^$(TAG)$$" || { \
		$(ECHO_ERR) "$(TAG) is not a tag."; \
		exit 1; \
	}
	$(GIT) push -f $(GIT_REMOTE) \
		$(shell $(GIT) rev-list -n1 $(TAG)):refs/heads/env/$(ENV_NAME) \
		$(shell $(GIT) rev-list -n1 $(TAG)):refs/tags/env/$(ENV_NAME)/$(MAKE_DATE)-$(MAKE_TIME)-$(TAG)
	$(GIT) fetch

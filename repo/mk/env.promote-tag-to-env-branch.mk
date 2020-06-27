SF_PROMOTE_ENVS += \
	dev \
	prod-staging \
	prod \

# ------------------------------------------------------------------------------

.PHONY: promote-env/%
promote-env/%: guard-env-GIT_REMOTE ## promote-env/<env>/<tag> Promote tag to env branch.
	$(eval ENV_NAME := $(shell dirname "$*"))
	$(eval ENV_BRANCH := env/$(ENV_NAME))
	$(eval TAG := $(shell basename "$*"))
	$(eval TAG_COMMIT := $(shell $(GIT) rev-list -n1 $(TAG)))
	$(ECHO) "$(SF_PROMOTE_ENVS)" | $(GREP) -q -e "\(^\|\s\)$(ENV_NAME)\(\s\|$$\)" || { \
		$(ECHO_ERR) "$(ENV_NAME) is not a known env."; \
		exit 1; \
	}
	$(GIT) tag --list | $(GREP) -q "^$(TAG)$$" || { \
		$(ECHO_ERR) "$(TAG) is not a tag."; \
		exit 1; \
	}
	$(GIT) fetch
	$(ECHO)
	$(ECHO_INFO) "Changes ready to be promoted:"
	$(ECHO)
	$(GIT) --no-pager log \
		--color \
		--graph \
		--date=short \
		--pretty=format:"%h %ad %s" \
		--no-decorate \
		$(GIT_REMOTE)/$(ENV_BRANCH)..$(TAG_COMMIT) | \
		$(GREP) --color -E "^|break" || true
	$(ECHO)
	$(ECHO_INFO) "Breaking changes ready to be promoted:"
	$(ECHO)
	$(GIT) --no-pager log \
		--color \
		--graph \
		--date=short \
		--pretty=format:"%h %ad %s" \
		--no-decorate \
		$(GIT_REMOTE)/$(ENV_BRANCH)..$(TAG_COMMIT) | \
		$(GREP) --color -E "break" || true
	$(ECHO)
	$(ECHO) "[Q   ] Still want to promote $(TAG) to $(ENV_BRANCH)?"
	$(ECHO) "       Press ENTER to Continue."
	$(ECHO) "       Press Ctrl+C to Cancel."
	read -p ""
	$(GIT) push --no-verify -f $(GIT_REMOTE) \
		$(TAG_COMMIT):refs/heads/$(ENV_BRANCH) \
		$(TAG_COMMIT):refs/tags/$(ENV_BRANCH)/$(MAKE_DATE)-$(MAKE_TIME)-$(TAG)
	$(GIT) fetch

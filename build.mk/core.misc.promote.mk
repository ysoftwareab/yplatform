# Adds a helper '_promote' target that esentially pushes a tag to a branch.

# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------

.PHONY: _promote
_promote: guard-env-SF_PROMOTE_CHANNEL
_promote: guard-env-SF_PROMOTE_CHANNELS
_promote: guard-env-SF_PROMOTE_BRANCH
_promote: guard-env-SF_PROMOTE_TAG
_promote: guard-env-GIT_REMOTE
_promote:
	$(eval TAG_COMMIT := $(shell $(GIT) rev-list -n1 $(SF_PROMOTE_TAG)))
	$(ECHO) "$(SF_PROMOTE_CHANNELS)" | $(GREP) -q -e "\(^\|\s\)$(SF_PROMOTE_CHANNEL)\(\s\|$$\)" || { \
		$(ECHO_ERR) "$(SF_PROMOTE_CHANNEL) is not a known promotion channel."; \
		$(ECHO_INFO) "Known promotion channels: $(SF_PROMOTE_CHANNELS)."; \
		exit 1; \
	}
	$(GIT) tag --list | $(GREP) -q "^$(SF_PROMOTE_TAG)$$" || { \
		$(ECHO_ERR) "$(SF_PROMOTE_TAG) is not a tag."; \
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
		$(GIT_REMOTE)/$(SF_PROMOTE_BRANCH)..$(TAG_COMMIT) | \
		$(GREP) --color -i -E "^|break" || true
	$(ECHO)
	$(ECHO_INFO) "Breaking changes ready to be promoted:"
	$(ECHO)
	$(GIT) --no-pager log \
		--color \
		--graph \
		--date=short \
		--pretty=format:"%h %ad %s" \
		--no-decorate \
		$(GIT_REMOTE)/$(SF_PROMOTE_BRANCH)..$(TAG_COMMIT) | \
		$(GREP) --color -E "break" || true
	$(ECHO)
	$(ECHO) "[Q   ] Still want to promote $(SF_PROMOTE_TAG) to $(SF_PROMOTE_BRANCH)?"
	$(ECHO) "       Press ENTER to Continue."
	$(ECHO) "       Press Ctrl+C to Cancel."
	read -p ""
	$(GIT) push --no-verify -f $(GIT_REMOTE) \
		$(TAG_COMMIT):refs/heads/$(SF_PROMOTE_BRANCH) \
		$(TAG_COMMIT):refs/tags/$(SF_PROMOTE_BRANCH)/$(MAKE_DATE)-$(MAKE_TIME)-$(SF_PROMOTE_TAG)
	$(GIT) fetch

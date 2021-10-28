# Adds a helper '_promote' target that esentially pushes a tag to a branch.

# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------

.PHONY: _promote
_promote: guard-env-YP_PROMOTE_CHANNEL
_promote: guard-env-YP_PROMOTE_CHANNELS
_promote: guard-env-YP_PROMOTE_BRANCH
_promote: guard-env-YP_PROMOTE_TAG
_promote: guard-env-GIT_REMOTE
_promote:
	$(eval TAG_COMMIT := $(shell $(GIT) rev-list -n1 $(YP_PROMOTE_TAG)))
	$(ECHO) "$(YP_PROMOTE_CHANNELS)" | $(GREP) -q -e "\(^\|\s\)$(YP_PROMOTE_CHANNEL)\(\s\|$$\)" || { \
		$(ECHO_ERR) "$(YP_PROMOTE_CHANNEL) is not a known promotion channel."; \
		$(ECHO_INFO) "Known promotion channels: $(YP_PROMOTE_CHANNELS)."; \
		exit 1; \
	}
	$(GIT) tag --list | $(GREP) -q "^$(YP_PROMOTE_TAG)$$" || { \
		$(ECHO_ERR) "$(YP_PROMOTE_TAG) is not a tag."; \
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
		$(GIT_REMOTE)/$(YP_PROMOTE_BRANCH)..$(TAG_COMMIT) | \
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
		$(GIT_REMOTE)/$(YP_PROMOTE_BRANCH)..$(TAG_COMMIT) | \
		$(GREP) --color -E "break" || true
	$(ECHO)
	$(ECHO) "[Q   ] Still want to promote $(YP_PROMOTE_TAG) to $(YP_PROMOTE_BRANCH)?"
	$(ECHO) "       Press ENTER to Continue."
	$(ECHO) "       Press Ctrl+C to Cancel."
	read -r -p "" -n1
	$(GIT) push --no-verify -f $(GIT_REMOTE) \
		$(TAG_COMMIT):refs/heads/$(YP_PROMOTE_BRANCH) \
		$(TAG_COMMIT):refs/tags/$(YP_PROMOTE_BRANCH)/$(MAKE_DATE)-$(MAKE_TIME)-$(YP_PROMOTE_TAG)
	$(GIT) fetch

# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------

.PHONY: _promote-channel-setup/%
_promote-channel-setup/%: guard-env-YP_PROMOTE_CHANNELS
	$(eval PROMOTE_CHANNEL := $(shell dirname "$*"))
	$(eval PROMOTE_BRANCH := $(PROMOTE_CHANNEL))
	$(eval PROMOTE_CHANNELS := $(YP_PROMOTE_CHANNELS))


.PHONY: promote-channel-in-channels-dir/%
promote-channel-in-channels-dir/%: _promote-channel-setup/% _promote


.PHONY: promote-channel/%
promote-channel/%: ## promote-channel/<channel>/<tag> Promote tag to a release channel.
	$(MAKE) \
		-C $(YP_PROMOTE_CHANNELS_DIR) \
		YP_PROMOTE_CHANNELS="$(YP_PROMOTE_CHANNELS)" \
		promote-channel-in-channels-dir/$*

SF_PROMOTE_ENVS += \
	dev \
	prod-staging \
	prod \

# ------------------------------------------------------------------------------

.PHONY: _promote-env-setup/%
_promote-env-setup/%: guard-env-SF_PROMOTE_ENVS
	$(eval PROMOTE_CHANNEL := $(shell dirname "$*"))
	$(eval PROMOTE_BRANCH := env/$(PROMOTE_CHANNEL))
	$(eval PROMOTE_CHANNELS := $(SF_PROMOTE_ENVS))


.PHONY: promote-env/%
promote-env/%: _promote-env-setup/% _promote ## promote-env/<env>/<tag> Promote tag to env branch.

# ------------------------------------------------------------------------------

.PHONY: _promote-env-setup/%
_promote-env-setup/%: guard-env-SF_PROMOTE_ENVS
	$(eval SF_PROMOTE_CHANNEL := $(shell dirname "$*"))
	$(eval SF_PROMOTE_BRANCH := env/$(SF_PROMOTE_CHANNEL))
	$(eval SF_PROMOTE_CHANNELS := $(SF_PROMOTE_ENVS))


.PHONY: promote-env/%
promote-env/%: _promote-env-setup/% ## promote-env/<env>/<tag> Promote tag to env branch.
	true && \
		SF_PROMOTE_BRANCH="$(SF_PROMOTE_BRANCH)" \
		SF_PROMOTE_CHANNEL="$(SF_PROMOTE_CHANNEL)" \
		SF_PROMOTE_CHANNELS="$(SF_PROMOTE_CHANNELS)" \
		SF_PROMOTE_TAG="$$(basename "$*")" \
		$(MAKE) _promote

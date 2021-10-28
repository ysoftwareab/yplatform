# ------------------------------------------------------------------------------

.PHONY: _promote-env-setup/%
_promote-env-setup/%: guard-env-YP_PROMOTE_ENVS
	$(eval YP_PROMOTE_CHANNEL := $(shell dirname "$*"))
	$(eval YP_PROMOTE_BRANCH := env/$(YP_PROMOTE_CHANNEL))
	$(eval YP_PROMOTE_CHANNELS := $(YP_PROMOTE_ENVS))


.PHONY: promote-env/%
promote-env/%: _promote-env-setup/% ## promote-env/<env>/<tag> Promote tag to env branch.
	true && \
		YP_PROMOTE_BRANCH="$(YP_PROMOTE_BRANCH)" \
		YP_PROMOTE_CHANNEL="$(YP_PROMOTE_CHANNEL)" \
		YP_PROMOTE_CHANNELS="$(YP_PROMOTE_CHANNELS)" \
		YP_PROMOTE_TAG="$$(basename "$*")" \
		$(MAKE) _promote

# This is a collection of internal targets implementing
# releasing new versions as git tags.
#
# ------------------------------------------------------------------------------

.PHONY: _publish
_publish:
	@$(ECHO_DO) "Publishing version..."
	$(GIT) push $(GIT_REMOTE) v`$(CAT) "package.json" | $(JQ) -r ".version"`
	@$(ECHO_DONE)


.PHONY: _release
_release:
	@$(ECHO_DO) "Release new $(VSN) version..."
	# $(MAKE) nuke all test version/v$(VSN) _publish
	# no need for 'nuke all test'
	$(MAKE) check version/v$(VSN) _publish
	sleep 15 # allow CI to pick the new tag first
	$(GIT) fetch
#	if upstream diverged, create merge commit or else `git push` fails
	[[ `$(GIT) rev-list --count HEAD..@{u}` = 0 ]] || { \
		$(ECHO_INFO) "Upstream has new commits..."; \
		$(GIT) --no-pager log \
			--graph \
			--date=short \
			--pretty=format:"%h %ad %s" \
			--no-decorate \
			`$(GIT) rev-parse HEAD`..`$(GIT) rev-parse @{u}`; \
		GIT_TAG=`$(GIT) tag -l --points-at HEAD | $(HEAD) -1`; \
		$(ECHO_INFO) "Merging in tag $${GIT_TAG}..."; \
		$(GIT) reset @{u}; \
		$(GIT) merge --no-ff refs/tags/$${GIT_TAG} -m "Merge tag $${GIT_TAG}"; \
	}
	$(GIT) push
	@$(ECHO_DONE)

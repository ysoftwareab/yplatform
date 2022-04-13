# This is a collection of "must have" targets for repositories with (release) channels,
# like desktop apps.
#
# "Channels" is a convention that states that releases (artifacts and/or metadata)
# are published externally to another git repository than the current one.
# This allows for the current repository, holding the codebase, to remain private
# and/or for the "releases" repository to hold an entirely different content (e.g. metadata)
# than the current repository.
# In other words, the "releases" repository needs to be public and make metadata
# accessible for update queries. The current repository doesn't need to do any of those.
#
# This is best described by an Electron app example hosted by github.com,
# where the app binaries can be assets in Github releases,
# and the metadata can be committed as JSON files in different branches,
# where each branch corresponds to a release channel e.g. stable, beta, canary, etc.
# Example: https://github.com/tobiipro/merlin-controller-electron-releases
#
# The "channels" convention is quite different
# than the "environments" convention implemented by env.common.mk
# which states that the current git repository holds both the codebase and the releases.
#
# The "releases" repository will be cloned locally,
# and promoting a tag to a channel is basically pushing a tag to a branch,
# basically updating the channel's metadata to point to new binaries.
# At this point, the desktop app will be able to discover the new metadata on the upcoming poll,
# and possibly present the user to update their version to the latest one.
#
# ------------------------------------------------------------------------------

# NOTE might be enough with core.common.mk
ifndef YP_GENERIC_COMMON_INCLUDES_DEFAULT
$(error Please include generic.common.mk, before including channels.common.mk)
endif

include $(YP_DIR)/build.mk/channels.deps.mk
include $(YP_DIR)/build.mk/channels.promote.mk

# ------------------------------------------------------------------------------

YP_PROMOTE_CHANNELS_GIT_URL := $(shell \
	$(GIT) remote -v 2>/dev/null | \
	$(GREP) -oP "(?<=\t).+" | \
	$(GREP) -oP ".+(?= \(fetch\))" | \
	$(HEAD) -n1 | \
	$(SED) "s/.git$$/-releases.git/")

YP_PROMOTE_CHANNELS_DIR := releases

YP_PROMOTE_CHANNELS += \
	canary \
	stable \

# ------------------------------------------------------------------------------

.PHONY: channels
channels: ## View the status of release channels.
	$(eval YP_PROMOTE_CHANNELS_REMOTE_REFS := $(patsubst %,refs/heads/$(GIT_REMOTE)/%,$(SF_PROMOTE_CHANNELS)))
	$(eval OLDEST_CHANNEL := $(shell \
		$(GIT) fetch 2>/dev/null >&2; \
		$(GIT) -C $(YP_PROMOTE_CHANNELS_DIR) \
			for-each-ref --format="%(committerdate:unix) %(refname:short)" $(YP_PROMOTE_CHANNELS_REMOTE_REFS) | \
		$(SORT) -k1 | \
		$(HEAD) -n1 | \
		$(CUT) -d" " -f2))
	$(ECHO)
	$(ECHO_INFO) "Commits since oldest channel:"
	$(ECHO)
	$(GIT) -C $(YP_PROMOTE_CHANNELS_DIR) --no-pager log \
		--color \
		--graph \
		--date=short \
		--pretty=format:"%h %ad %s" \
		--no-decorate \
		$(GIT_REMOTE)/$(OLDEST_CHANNEL).. | \
		$(GREP) --color -i -E "^|break" || true

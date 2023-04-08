# sync with  sh/git.inc.sh

GIT_DIR = $(shell $(GIT) rev-parse --git-dir 2>/dev/null)
GIT_BRANCH = $(shell $(GIT) rev-parse --abbrev-ref HEAD 2>/dev/null)
GIT_BRANCH_SHORT = $(notdir $(GIT_BRANCH))
GIT_COMMIT_MSG = $(shell $(GIT) log -1 --format="%B" 2>/dev/null)
GIT_DESCRIBE = $(shell $(GIT) describe --tags --first-parent --always --dirty 2>/dev/null)
GIT_HASH = $(shell $(GIT) rev-parse HEAD 2>/dev/null)
GIT_HASH_SHORT = $(shell $(GIT) rev-parse --short HEAD 2>/dev/null)
GIT_TAGS = $(shell $(GIT) tag --points-at HEAD 2>/dev/null)
GIT_TAG = $(shell $(GIT) tag --points-at HEAD | $(HEAD) -n1 2>/dev/null)

ifdef SEMAPHORE_GIT_BRANCH
GIT_BRANCH = $(SEMAPHORE_GIT_BRANCH)
endif

ifdef TRAVIS_BRANCH
GIT_BRANCH = $(TRAVIS_BRANCH)
endif

GIT_REMOTE = $(shell $(GIT) config branch.$(GIT_BRANCH).remote 2>/dev/null)
GIT_REMOTE_OR_ORIGIN = $(shell GIT_REMOTE=$(GIT_REMOTE); $(ECHO) $${GIT_REMOTE:-origin})
GIT_ROOT = $(shell $(GIT) rev-parse --show-toplevel 2>/dev/null)
$(foreach VAR,GIT_REMOTE GIT_REMOTE_OR_ORIGIN GIT_ROOT,$(call make-lazy-once,$(VAR)))

GIT_REMOTE_URL = $(shell $(GIT) config remote.$(GIT_REMOTE).url 2>/dev/null)
# editorconfig-checker-disable max_line_length
# NOTE cannot use # editorconfig-checker-disable-line because it might add faux whitespace
GIT_REMOTE_SLUG = $(shell test -n $(GIT_REMOTE_URL) || GIT_REMOTE_URL=$(GIT_REMOTE_URL); basename $$(dirname "$${GIT_REMOTE_URL//://}"))/$(shell basename "$(GIT_REMOTE_URL)" .git)
# editorconfig-checker-enable max_line_length

GIT_REMOTE_OR_ORIGIN_URL = $(shell $(GIT) config remote.$(GIT_REMOTE_OR_ORIGIN).url 2>/dev/null)
# editorconfig-checker-disable max_line_length
# NOTE cannot use # editorconfig-checker-disable-line because it might add faux whitespace
GIT_REMOTE_OR_ORIGIN_SLUG = $(shell test -n $(GIT_REMOTE_OR_ORIGIN_URL) || GIT_REMOTE_OR_ORIGIN_URL=$(GIT_REMOTE_OR_ORIGIN_URL); basename $$(dirname "$${GIT_REMOTE_OR_ORIGIN_URL//://}"))/$(shell basename "$(GIT_REMOTE_OR_ORIGIN_URL)" .git)
# editorconfig-checker-enable max_line_length

GIT_REPO_HAS_CHANGED_FILES = $(shell $(GIT) status --porcelain | $(GREP) -q -v -e "^$$" && \
	$(ECHO) true || $(ECHO) false)
GIT_REPO_HAS_STAGED_FILES = $(shell $(GIT) status --porcelain | $(GREP) -q -e "^[^ U\?]" && \
	$(ECHO) true || $(ECHO) false)
GIT_REPO_HAS_UNSTAGED_FILES = $(shell $(GIT) status --porcelain | $(GREP) -q -e "^ [^ ]" && \
	$(ECHO) true || $(ECHO) false)
GIT_REPO_HAS_UNTRACKED_FILES = $(shell $(GIT) status --porcelain | $(GREP) -q -e "^?\?" && \
	$(ECHO) true || $(ECHO) false)
GIT_REPO_HAS_CONFLICTS = $(shell $(GIT) status --porcelain | $(GREP) -q -e "^\(DD\|AU\|UD\|UA\|DU\|AA\|UU\)" && \
	$(ECHO) true || $(ECHO) false)

GITHUB_SERVER_URL ?= https://github.com
GITHUB_SERVER_URL_DOMAIN ?= $(shell basename "$(GITHUB_SERVER_URL)")

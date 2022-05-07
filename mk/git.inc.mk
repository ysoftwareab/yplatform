# sync with  sh/git.inc.sh

GIT_DIR = $(shell $(GIT) rev-parse --git-dir 2>/dev/null)
GIT_BRANCH = $(shell $(GIT) rev-parse --abbrev-ref HEAD 2>/dev/null)
GIT_BRANCH_SHORT = $(notdir $(GIT_BRANCH))
GIT_COMMIT_MSG = $(shell $(GIT) log -1 --format="%B" 2>/dev/null)
GIT_DESCRIBE = $(shell $(GIT) describe --tags --first-parent --always --dirty 2>/dev/null)
GIT_HASH = $(shell $(GIT) rev-parse HEAD 2>/dev/null)
GIT_HASH_SHORT = $(shell $(GIT) rev-parse --short HEAD 2>/dev/null)
GIT_TAGS = $(shell $(GIT) tag --points-at HEAD 2>/dev/null)

ifdef SEMAPHORE_GIT_BRANCH
GIT_BRANCH = $(SEMAPHORE_GIT_BRANCH)
endif

ifdef TRAVIS_BRANCH
GIT_BRANCH = $(TRAVIS_BRANCH)
endif

GIT_REMOTE = $(shell $(GIT) config branch.$(GIT_BRANCH).remote 2>/dev/null)
GIT_REMOTE_OR_ORIGIN = $(shell $(GIT) config branch.$(GIT_BRANCH).remote 2>/dev/null | \
	$(YP_DIR)/bin/ifne -p -n "$(ECHO) origin")
GIT_ROOT = $(shell $(GIT) rev-parse --show-toplevel 2>/dev/null)
$(foreach VAR,GIT_REMOTE GIT_REMOTE_OR_ORIGIN GIT_ROOT,$(call make-lazy-once,$(VAR)))

GIT_REPO_HAS_CHANGED_FILES = $(shell $(GIT) status --porcelain | $(GREP) -q -v -e "^$$" && \
	$(ECHO) true || $(ECHO) false)
GIT_REPO_HAS_STAGED_FILES = $(shell $(GIT) status --porcelain | $(GREP) -q -e "^[^ U\?]" && \
	$(ECHO) true || $(ECHO) false)
GIT_REPO_HAS_UNSTAGED_FILES = $(shell $(GIT) status --porcelain | $(GREP) -q -e "^ [^ ]" && \
	$(ECHO) true || $(ECHO) false)
GIT_REPO_HAS_UNTRACKED_FILES = $(shell $(GIT) status --porcelain | $(GREP) -q -e "^\?\?" && \
	$(ECHO) true || $(ECHO) false)
GIT_REPO_HAS_CONFLICTS = $(shell $(GIT) status --porcelain | $(GREP) -q -e "^\(DD\|AU\|UD\|UA\|DU\|AA\|UU\)" && \
	$(ECHO) true || $(ECHO) false)

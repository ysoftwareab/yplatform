GIT_BRANCH = $(shell cd $(TOP) && $(GIT) rev-parse --abbrev-ref HEAD 2>/dev/null)
GIT_BRANCH_SHORT = $(notdir $(GIT_BRANCH))
GIT_DESCRIBE = $(shell cd $(TOP) && $(GIT) describe --first-parent --always --dirty)
GIT_HASH = $(shell cd $(TOP) && $(GIT) rev-parse HEAD 2>/dev/null)
GIT_HASH_SHORT = $(shell cd $(TOP) && $(GIT) rev-parse --short HEAD 2>/dev/null)
GIT_TAGS = $(shell $(GIT) tag --points-at HEAD 2>/dev/null)
$(foreach VAR,GIT_BRANCH GIT_BRANCH_SHORT GIT_DESCRIBE GIT_HASH GIT_HASH_SHORT GIT_TAGS,$(call make-lazy-once,$(VAR)))

GIT_REMOTE = $(shell $(GIT) config branch.$(GIT_BRANCH).remote 2>/dev/null)
GIT_ROOT = $(shell cd $(TOP) && $(GIT) rev-parse --show-toplevel 2>/dev/null)
$(foreach VAR,GIT_REMOTE GIT_ROOT,$(call make-lazy-once,$(VAR)))

GIT_REPO_HAS_CHANGED_FILES = $(shell $(GIT) status --porcelain | $(GREP) -q -v -e "^$$" && \
	echo true || echo false)
GIT_REPO_HAS_STAGED_FILES = $(shell $(GIT) status --porcelain | $(GREP) -q -e "^[^ U\?]" && \
	echo true || echo false)
GIT_REPO_HAS_UNSTAGED_FILES = $(shell $(GIT) status --porcelain | $(GREP) -q -e "^ [^ ]" && \
	echo true || echo false)
GIT_REPO_HAS_UNTRACKED_FILES = $(shell $(GIT) status --porcelain | $(GREP) -q -e "^\?\?" && \
	echo true || echo false)
GIT_REPO_HAS_CONFLICTS = $(shell $(GIT) status --porcelain | $(GREP) -q -e "^\(DD\|AU\|UD\|UA\|DU\|AA\|UU\)" && \
	echo true || echo false)

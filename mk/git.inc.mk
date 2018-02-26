GIT_BRANCH = $(shell cd $(TOP) && git rev-parse --abbrev-ref HEAD 2>/dev/null)
GIT_BRANCH_SHORT = $(shell basename $(GIT_BRANCH))
GIT_HASH = $(shell cd $(TOP) && git rev-parse HEAD 2>/dev/null)
GIT_HASH_SHORT = $(shell cd $(TOP) && git rev-parse --short HEAD 2>/dev/null)
GIT_REMOTE = $(shell git config branch.$(GIT_BRANCH).remote 2>/dev/null)
GIT_ROOT = $(shell cd $(TOP) && git rev-parse --show-toplevel 2>/dev/null)
GIT_TAG = $(shell git describe --exact-match --tags HEAD 2>/dev/null)

ifeq (true,$(TRAVIS))
GIT_BRANCH = $(TRAVIS_BRANCH)
export TRAVIS_TAG := $(GIT_TAG) # FIXME https://github.com/travis-ci/travis-ci/issues/9268
GIT_TAG = $(TRAVIS_TAG)
endif

$(foreach VAR,GIT_BRANCH GIT_BRANCH_SHORT GIT_HASH GIT_HASH_SHORT GIT_REMOTE GIT_ROOT GIT_TAG,$(call make-lazy,$(VAR)))

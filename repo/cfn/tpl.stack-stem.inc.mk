# example where "env-web" is a stack stem placeholder e.g. env-api/env-web/infra/ci/etc

.PHONY: <STACK_STEM>-setup
<STACK_STEM>-setup:
	$(eval STACK_STEM := <STACK_STEM>)
#	$(eval STACK_NAME := $(ENV_NAME)-web) # in case on env-* stacks only

define <STACK_STEM>-lint
endef

define <STACK_STEM>-pre
endef

define <STACK_STEM>-pre-exec
endef

define <STACK_STEM>-post-exec
endef

define <STACK_STEM>-pre-rm
endef

define <STACK_STEM>-post-rm
endef

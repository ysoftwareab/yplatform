# CHECK ENVIRONMENT VARIABLE
# Usage:
# my-target: env-guard-HOST
# means my-target depends on $HOST being set
.PHONY: env-guard-%
env-guard-%:
	@if [ "${${*}}" == "" ]; then \
		echo "Environment variable $* is not set"; \
		exit 1; \
	fi


# CHECK EXECUTABLE
.PHONY: env-has-%
env-has-%:
	@command -v "${*}" >/dev/null 2>&1


# silent TARGET
# Usage:
# my-target: my-optional-target | silent
.PHONY: silent
silent:
	@:


# help TARGET (list all available targets)
# From http://stackoverflow.com/a/15058900
.PHONY: help
help:
#	@sh -c "$(MAKE) -p silent | awk -F':' '/^[a-zA-Z0-9][^\$$#\/\\t=]*:([^=]|$$)/ {split(\$$1,A,/ /);for(i in A)print A[i]}' | grep -v '__\$$' | grep -v -e 'env-guard-*' -e 'env-has-*' -e 'make' -e 'Makefile' | sort | uniq"
	@$(MAKE) -p silent | \
		pcregrep -e '^[a-zA-Z0-9]+:' | \
		sed 's/:.*//' | \
		pcregrep -v -e 'make' | \
		pcregrep -v -e 'silent' | \
		sort | \
		uniq


# usage TARGET (echo USAGE information)
.PHONY: usage
usage: env-has-USAGE
	@echo "$$USAGE"

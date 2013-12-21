# CHECK ENVIRONMENT VARIABLE
# Usage:
# my-target: env-guard-HOST
# means my-target depends on $HOST being set
.PHONY: util-env-guard-%
util-env-guard-%:
	@if [[ "$${${*}}" == "" ]]; then \
		echo "ERROR: Environment variable ${*} is not defined!"; \
		exit -1; \
	fi


# CHECK EXECUTABLE
.PHONY: util-env-has-%
util-env-has-%:
	@command -v "${*}" >/dev/null 2>&1 || { \
		echo "ERROR: Please install ${*}!"; \
		exit -1; \
	}


# silent TARGET
# Usage:
# my-target: my-optional-target | util-silent
.PHONY: util-silent
util-silent:
	@:


# help TARGET (list all available targets)
# From http://stackoverflow.com/a/15058900
.PHONY: util-help
util-help:
#	@sh -c "$(MAKE) -p silent | awk -F':' '/^[a-zA-Z0-9][^\$$#\/\\t=]*:([^=]|$$)/ {split(\$$1,A,/ /);for(i in A)print A[i]}' | grep -v '__\$$' | grep -v -e 'env-guard-*' -e 'env-has-*' -e 'make' -e 'Makefile' | sort | uniq"
	@$(MAKE) -p util-silent | \
		pcregrep -e '^[a-zA-Z0-9]+:' | \
		sed 's/:.*//' | \
		pcregrep -v -e 'make' | \
		pcregrep -v -e 'Makefile' | \
		pcregrep -v -e 'util-*' | \
		sort | \
		uniq


# usage TARGET (echo USAGE information)
.PHONY: util-usage
util-usage: util-env-guard-USAGE
	@echo "$$USAGE"

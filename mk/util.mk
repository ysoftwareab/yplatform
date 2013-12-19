# CHECK ENVIRONMENT VARIABLE
# Usage:
# my-target: guard-env-HOST
# means my-target depends on $HOST being set
guard-env-%:
	@if [ "${${*}}" == "" ]; then \
		echo "Environment variable $* is not set"; \
		exit 1; \
	fi


# CHECK EXECUTABLE
has-%:
	@which "${*}" > /dev/null


# silent TARGET
# Usage:
# my-target: my-optional-target | silent
silent:
	@:


# help TARGET (list all available targets)
# From http://stackoverflow.com/a/15058900
help:
#	@sh -c "$(MAKE) -p silent | awk -F':' '/^[a-zA-Z0-9][^\$$#\/\\t=]*:([^=]|$$)/ {split(\$$1,A,/ /);for(i in A)print A[i]}' | grep -v '__\$$' | grep -v -e 'guard-*' -e 'has-*' -e 'make' -e 'Makefile' | sort | uniq"
	@$(MAKE) -p silent | \
		pcregrep -e '^[a-zA-Z0-9]+:' | \
		sed 's/:.*//' | \
		pcregrep -v -e 'make' | \
		pcregrep -v -e 'silent' | \
		sort | \
		uniq


# usage TARGET (echo USAGE information)
usage: has-env-USAGE
	@echo "$$USAGE"

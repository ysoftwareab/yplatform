# https://raw.githubusercontent.com/andreineculau/util.mk/master/util.mk

# Uniq words in string
# From https://stackoverflow.com/a/16151140/465684
define uniq
$(eval SEEN :=)
$(foreach _,$1,$(if $(filter $_,$(SEEN)),,$(eval SEEN += $_)))
$(SEEN)
endef

# PRINT MAKEFILE VARIABLES
.PHONY: print-all
print-all:
	@$(foreach V,$(sort $(.VARIABLES)),
		$(if $(filter-out environment% default automatic,
		$(origin $V)),$(warning $V=$($V) ($(value $V)))))


# PRINT MAKEFILE VARIABLE
# From http://blog.jgc.org/2015/04/the-one-line-you-should-add-to-every.html
# See also https://www.cmcrossroads.com/article/printing-value-makefile-variable
.PHONY: print-%
print-%:
	@echo $*=$($*)


# CHECK ENVIRONMENT VARIABLE
# Usage:
# my-target: env-guard-HOST
# means my-target depends on $HOST being set
.PHONY: env-guard-%
env-guard-%:
	@if [[ "$${${*}}" == "" ]]; then \
		echo "ERROR: Environment variable ${*} is not defined!"; \
		exit -1; \
	fi


# CHECK EXECUTABLE
.PHONY: env-has-%
env-has-%:
	@command -v "${*}" >/dev/null 2>&1 || { \
		echo "ERROR: Please install ${*}!"; \
		exit -1; \
	}


# silent TARGET
# Usage:
# my-target: my-optional-target | util-silent
.PHONY: silent
silent:
	@:


# help TARGET (list all available targets)
# From http://stackoverflow.com/a/15058900
# See also https://www.cmcrossroads.com/article/self-documenting-makefiles
.PHONY: help
help:
#	@sh -c "$(MAKE) -p silent | awk -F':' '/^[a-zA-Z0-9][^\$$#\/\\t=]*:([^=]|$$)/ {split(\$$1,A,/ /);for(i in A)print A[i]}' | grep -v '__\$$' | grep -v -e 'env-guard-*' -e 'env-has-*' -e 'make' -e 'Makefile' | sort | uniq"
	@$(MAKE) -p util-silent | \
		pcregrep -e '^[a-zA-Z0-9][^\$$#\\t=]*:' | \
		pcregrep -v -e ':=' | \
		sed 's/:.*//' | \
		pcregrep -v -e 'make' | \
		pcregrep -v -e 'Makefile' | \
		pcregrep -v -e 'util-*' | \
		sort | \
		uniq

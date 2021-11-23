.PHONY: guard-env-%
guard-env-%: # Guard on environment variable.
	@if [ "$($*)" = "" ] && [ "$${$*:-}" = "" ]; then \
		$(ECHO) >&2 "ERROR: Environment variable $* is not defined!"; \
		exit 1; \
	fi


.PHONY: guard-env-has-%
guard-env-has-%: # Guard on environment executable.
	@command -v "${*}" >/dev/null 2>&1 || { \
		$(ECHO) >&2 "ERROR: Please install ${*}!"; \
		exit 1; \
	}

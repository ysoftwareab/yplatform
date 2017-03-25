.PHONY: env-guard-%
env-guard-%: # Guard on environment variable.
	@if [ "$($*)" = "" ] && [ "$${$*:-}" = "" ]; then \
		echo >&2 "ERROR: Environment variable $* is not defined!"; \
		exit 1; \
	fi


.PHONY: env-has-%
env-has-%: # Guard on environment executable.
	@command -v "${*}" >/dev/null 2>&1 || { \
		echo >&2 "ERROR: Please install ${*}!"; \
		exit 1; \
	}

# WHICH_Q is kept for backward compatibility
WHICH_Q := 2>/dev/null which
COMMAND_Q := 2>/dev/null command -v

# NOTE can't use $(ECHO)
define global-which
$(shell \
	hash -r; \
	export RESULT="$$(for CMD in $(2); do $(COMMAND_Q) $${CMD} && break || continue; done)"; \
	echo "$${RESULT:-$(1)_NOT_FOUND}")
endef
PRINTVARS_VARIABLES_IGNORE += global-which

# NOTE can't use $(ECHO)
define which
$(shell \
	export PATH="$(PATH)"; \
	hash -r; \
	export RESULT="$$(for CMD in $(2); do $(COMMAND_Q) $${CMD} && break || continue; done)"; \
	echo "$${RESULT:-$(1)_NOT_FOUND}")
endef
PRINTVARS_VARIABLES_IGNORE += which

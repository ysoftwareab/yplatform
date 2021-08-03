# WHICH_Q is kept for backward compatibility
WHICH_Q := 2>/dev/null which
COMMAND_Q := 2>/dev/null command -v

define global-which
	$(shell export RESULT="$$(for CMD in $(2); do $(COMMAND_Q) $${CMD} && break || continue; done)"; echo "$${RESULT:-$(1)_NOT_FOUND}")
endef

define which
	$(shell export PATH="$(PATH)"; export RESULT="$$(for CMD in $(2); do $(COMMAND_Q) $${CMD} && break || continue; done)"; echo "$${RESULT:-$(1)_NOT_FOUND}")
endef

include $(CORE_INC_MK_DIR)/exe.gnu.inc.mk
include $(CORE_INC_MK_DIR)/exe.echo.inc.mk
include $(CORE_INC_MK_DIR)/exe.misc.inc.mk

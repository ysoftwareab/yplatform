WHICH_Q := 2>/dev/null which

define global-which
$(shell export RESULT="$$(for CMD in $(2); do $(WHICH_Q) $${CMD} && break || continue; done)"; echo "$${RESULT:-$(1)_NOT_FOUND}")
endef

define which
$(shell PATH="$(PATH)" export RESULT="$$(for CMD in $(2); do $(WHICH_Q) $${CMD} && break || continue; done)"; echo "$${RESULT:-$(1)_NOT_FOUND}")
endef

include $(CORE_INC_MK_PATH)/exe.gnu.inc.mk
include $(CORE_INC_MK_PATH)/exe.echo.inc.mk
include $(CORE_INC_MK_PATH)/exe.misc.inc.mk

.VARIABLES_LAZY += \

# Turn variable into a lazy variable, evaluated only once per Makefile or on-demand per make call
# ref http://blog.jgc.org/2016/07/lazy-gnu-make-variables.html
# NOTE: requires make >3.81 (default on macos) due to https://savannah.gnu.org/patch/?7534 and similar
# NOTE: 3.81 might throw an "*** unterminated variable reference.  Stop." error
# * 'make-lazy' will bulk evaluate once and forever by generating a 'Makefile.lazy' file,
#   and skip evaluation until Makefile.lazy is removed
# * 'make-lazy-once' will evaluate once per make session
make-lazy-major-version-problematic := 3.81 3.82
make-lazy-major-version-problematic := $(filter $(MAKE_VERSION),$(make-lazy-major-version-problematic))
ifeq (,$(make-lazy-major-version-problematic))
make-lazy = $(eval $1 = $$(eval $1 := $(value $(1)))$$($1))$(eval .VARIABLES_LAZY += $1)
make-lazy-once = $(eval $1 = $$(eval $1 := $(value $(1)))$$($1))
else
$(warning The 'make-lazy' function cannot run on GNU Make $(MAKE_VERSION). Disabling.)
make-lazy =
$(warning The 'make-lazy-once' function cannot run on GNU Make $(MAKE_VERSION). Disabling.)
make-lazy-once =
endif

# Complex ifdef
# From http://stackoverflow.com/questions/5584872/complex-conditions-check-in-makefile
ifndef_any_of = $(filter undefined,$(foreach v,$(1),$(origin $(v))))
ifdef_any_of = $(filter-out undefined,$(foreach v,$(1),$(origin $(v))))
# ifdef VAR1 || VAR2 -> ifneq ($(call ifdef_any_of,VAR1 VAR2),)
# ifdef VAR1 && VAR2 -> ifeq ($(call ifndef_any_of,VAR1 VAR2),)

# Export if defined
define exportifdef
ifdef $(1)
export $(1)
endif
endef

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

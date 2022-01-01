# Sources CONST.inc and CONST.inc.secret (a transcrypted file).
#
# CONST.inc is a "env" file, meaning it contains "VAR=VALUE" lines
# as well as empty or comment lines (prefixed with #).
# Both GNU Make and Bash should be able to include/source it without problems.
#
# ------------------------------------------------------------------------------

# CONST.inc
ifneq (,$(wildcard $(GIT_ROOT)/CONST.inc))
include $(GIT_ROOT)/CONST.inc
export $(shell $(SED) 's/=.\{0,\}//' $(GIT_ROOT)/CONST.inc)
endif

# CONST.inc.secret
ifneq (,$(wildcard $(GIT_ROOT)/CONST.inc.secret))
YP_IS_TRANSCRYPTED ?=
ifeq (true,$(YP_IS_TRANSCRYPTED))

include $(GIT_ROOT)/CONST.inc.secret
export $(shell $(SED) 's/=.\{0,\}//' $(GIT_ROOT)/CONST.inc.secret)

endif
endif

# ------------------------------------------------------------------------------

# SF_CI_ECHO can be used for e.g. pointing to
# an executable that outputs teamcity messages

SF_CI_ECHO ?= $(ECHO)
ECHO_DO = $(SF_CI_ECHO) "[DO  ]"
ECHO_DONE = $(SF_CI_ECHO) "[DONE]"
ECHO_INFO = $(SF_CI_ECHO) "[INFO]"
ECHO_SKIP = $(SF_CI_ECHO) "[SKIP]"
ECHO_WARN = $(SF_CI_ECHO) "[WARN]"
ECHO_ERR = $(SF_CI_ECHO) "[ERR ]"
$(foreach VAR,ECHO SF_CI_ECHO ECHO_DO ECHO_DONE ECHO_INFO ECHO_SKIP ECHO_WARN ECHO_ERR,$(call make-lazy,$(VAR)))

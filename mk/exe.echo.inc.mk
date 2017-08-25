# CI_ECHO can be used for e.g. pointing to
# an executable that outputs teamcity messages

CI_ECHO ?= $(ECHO)
ECHO_DO = $(CI_ECHO) "[DO  ]"
ECHO_DONE = $(CI_ECHO) "[DONE]"
ECHO_INFO = $(CI_ECHO) "[INFO]"
ECHO_SKIP = $(CI_ECHO) "[SKIP]"
ECHO_WARN = $(CI_ECHO) "[WARN]"
ECHO_ERR = $(CI_ECHO) "[ERR ]"
$(foreach VAR,ECHO CI_ECHO ECHO_DO ECHO_DONE ECHO_INFO ECHO_SKIP ECHO_WARN ECHO_ERR,$(call make-lazy,$(VAR)))

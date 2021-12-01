# YP_CI_ECHO can be used for e.g. pointing to
# an executable that outputs teamcity messages

YP_CI_ECHO ?= $(ECHO)
ECHO_DO = $(YP_CI_ECHO) -- "[DO  ]"
ECHO_DONE = $(YP_CI_ECHO) -- "[DONE]"
ECHO_INFO = $(YP_CI_ECHO) -- "[INFO]"
ECHO_SKIP = $(YP_CI_ECHO) -- "[SKIP]"
ECHO_WARN = $(YP_CI_ECHO) -- "[WARN]"
ECHO_ERR = $(YP_CI_ECHO) -- "[ERR ]"
$(foreach VAR,ECHO YP_CI_ECHO ECHO_DO ECHO_DONE ECHO_INFO ECHO_SKIP ECHO_WARN ECHO_ERR,$(call make-lazy,$(VAR)))

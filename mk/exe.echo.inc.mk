# YP_CI_ECHO can be used for e.g. pointing to
# an executable that outputs teamcity messages

YP_CI_ECHO ?= $(ECHO)
ECHO_DO = $(YP_CI_ECHO) -- "[DO  ]"
ECHO_DONE = $(YP_CI_ECHO) -- "[DONE]"
ECHO_INDENT = $(YP_CI_ECHO) -- "      "
ECHO_NEXT = $(YP_CI_ECHO) -- "[NEXT]"
ECHO_Q = $(YP_CI_ECHO) -- "[Q   ]"
ECHO_SKIP = $(YP_CI_ECHO) -- "[SKIP]"

ECHO_ERR = $(YP_CI_ECHO) -- "[ERR ]"
ECHO_INFO = $(YP_CI_ECHO) -- "[INFO]"
ECHO_WARN = $(YP_CI_ECHO) -- "[WARN]"

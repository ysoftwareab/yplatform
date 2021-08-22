MAKEFILE := $(firstword $(MAKEFILE_LIST))
# From http://stackoverflow.com/questions/18136918/how-to-get-current-directory-of-your-makefile
MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
PWD := $(notdir $(patsubst %/,%,$(dir $(MAKEFILE_PATH))))

ifndef CORE_INC_MK_DIR
CORE_INC_MK_DIR = $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))
endif

SHELL := env MAKEFLAGS= MFLAGS= bash
# .SHELLFLAGS := -euo pipefail -O globstar -c # BASH v4
.SHELLFLAGS := -euo pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SECONDARY:
.SUFFIXES:
.NOTPARALLEL:

MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

CI ?=

ifeq (1,$(CI))
CI := true
endif

VERBOSE ?=
V ?= $(VERBOSE)
VERBOSE := $(V)

ifeq (1,$(VERBOSE))
VERBOSE := true
endif

ifneq (true,$(VERBOSE))
MAKEFLAGS += -s
ifeq (true,$(CI))
MAKEFLAGS += --no-print-directory
else
MAKEFLAGS += --print-directory
endif
else
.SHELLFLAGS := -x $(.SHELLFLAGS)
MAKEFLAGS += --print-directory
endif

# ------------------------------------------------------------------------------

MAKE_DATE := $(shell date +'%y%m%d')
MAKE_TIME := $(shell date +'%H%M%S')

MAKE_FILENAME = $(notdir $(firstword $(MAKEFILE_LIST)))
MAKE_PATH = $(patsubst %/,%,$(dir $(abspath $(firstword $(MAKEFILE_LIST)))))
MAKE_REALPATH = $(patsubst %/,%,$(dir $(realpath "$(MAKE_PATH)/$(MAKE_FILENAME)")))
$(foreach VAR,MAKE_FILENAME MAKE_PATH MAKE_REALPATH,$(call make-lazy,$(VAR)))

MAKE_SELF_FILENAME = $(notdir $(lastword $(MAKEFILE_LIST)))
MAKE_SELF_PATH = $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

TOP ?= $(MAKE_PATH)
TOP_REL = $(shell python -c "import os.path; print('%s' % os.path.relpath('$(TOP)', '$(MAKE_PATH)'))")
$(foreach VAR,TOP TOP_REL,$(call make-lazy-once,$(VAR)))

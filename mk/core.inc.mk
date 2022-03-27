ifndef CORE_INC_MK_DIR
CORE_INC_MK_DIR = $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))
endif

SHELL := env MAKEFLAGS= MFLAGS= bash
# .SHELLFLAGS := -euo pipefail -o errtrace -o functrace -O globstar -c # BASH v4
.SHELLFLAGS := -euo pipefail -o errtrace -o functrace -c
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

ifeq (2,$(VERBOSE))
VERBOSE := true
# see https://www.runscripts.com/support/guides/scripting/bash/debugging-bash/verbose-tracing
# NOTE can't use $(DATE)
export PS4:=+ $$(date +"%Y-%m-%d %H:%M:%S") +$${SECONDS}s $${BASH_SOURCE[0]:-}:$${LINENO} +$(\n)
endif

CI_TF := $(shell [[ "$(CI)" = "true" ]] && echo true || echo false)
VERBOSE_TF := $(shell [[ "$(VERBOSE)" = "true" ]] && echo true || echo false)

MAKEFLAG_MAYBE_PRINT_DIRECTORY := --print-directory
ifneq (,$(findstring --no-print-directory,$(MAKEFLAGS)))
	MAKEFLAG_MAYBE_PRINT_DIRECTORY :=
endif

MAKEFLAG_MAYBE_NO_PRINT_DIRECTORY := --no-print-directory
ifneq (,$(findstring -w,$(MAKEFLAGS))$(findstring --print-directory,$(MAKEFLAGS)))
	MAKEFLAG_MAYBE_NO_PRINT_DIRECTORY :=
endif

ifeq (false-true,$(VERBOSE_TF)-$(CI_TF))
MAKEFLAGS += -s $(MAKEFLAG_MAYBE_NO_PRINT_DIRECTORY)
else ifeq (false-false,$(VERBOSE_TF)-$(CI_TF))
MAKEFLAGS += -s $(MAKEFLAG_MAYBE_PRINT_DIRECTORY)
else ifeq (true,$(VERBOSE_TF))
.SHELLFLAGS := -x $(.SHELLFLAGS)
MAKEFLAGS += $(MAKEFLAG_MAYBE_PRINT_DIRECTORY)
endif

ifneq (,$(filter undefine,$(.FEATURES)))
undefine CI_TF
undefine MAKEFLAGS_HAS_NO_PRINT_DIRECTORY_TF
undefine VERBOSE_TF
endif

# ------------------------------------------------------------------------------

# NOTE can't use $(DATE)
MAKE_DATE := $(shell date +'%y%m%d')
MAKE_TIME := $(shell date +'%H%M%S')

MAKE_FILENAME = $(notdir $(firstword $(MAKEFILE_LIST)))
MAKE_PATH = $(patsubst %/,%,$(dir $(abspath $(firstword $(MAKEFILE_LIST)))))
MAKE_REALPATH = $(patsubst %/,%,$(dir $(realpath "$(MAKE_PATH)/$(MAKE_FILENAME)")))
$(foreach VAR,MAKE_FILENAME MAKE_PATH MAKE_REALPATH,$(call make-lazy,$(VAR)))

MAKE_SELF_FILENAME = $(notdir $(lastword $(MAKEFILE_LIST)))
MAKE_SELF_PATH = $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

TOP ?= $(MAKE_PATH)
# NOTE can't use $(PYTHON)
TOP_REL = $(shell python -c "import os.path; print('%s' % os.path.relpath('$(TOP)', '$(MAKE_PATH)'))")
$(foreach VAR,TOP TOP_REL,$(call make-lazy-once,$(VAR)))

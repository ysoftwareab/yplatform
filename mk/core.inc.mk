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

# ------------------------------------------------------------------------------

# use MAKEFLAGS_SHORT for finding short flags: $(findstring "s",$(MAKEFLAGS_SHORT))
MAKEFLAGS_SHORT = $(firstword -$(MAKEFLAGS))

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

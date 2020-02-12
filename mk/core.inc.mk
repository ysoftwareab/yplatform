CORE_INC_MK_DIR ?= $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

SHELL := bash
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

# Turn variable into a lazy variable, evaluated only once, on demand
# ref http://blog.jgc.org/2016/07/lazy-gnu-make-variables.html
make-lazy = $(eval $1 = $$(eval $1 := $(value $(1)))$$($1))

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

# see https://blog.jgc.org/2007/06/escaping-comma-and-space-in-gnu-make.html
# $(,)
, := ,

# $( )
# NOT WORKING AFTER GNUMake 4.3
# space :=
# space +=
# $(space) :=
# $(space) +=
empty :=
space := $(empty) $(empty)
$(space) := $(empty) $(empty)

# $(=)
equals := =
$(equals) := =

# $(#)
hash := \#
$(hash) := \#

# $(:)
colon := :
$(colon) := :

# $($$)
dollar := $$
$(dollar) := $$

# $(;)
; := ;

# $(%)
% := %

# $(\n)
define \n


endef

# ------------------------------------------------------------------------------

MAKE_DATE := $(shell date +'%y%m%d')
MAKE_TIME := $(shell date +'%H%M%S')

MAKE_FILENAME = $(shell basename $(firstword $(MAKEFILE_LIST)))
MAKE_PATH = $(shell dirname $(abspath $(firstword $(MAKEFILE_LIST))))
MAKE_REALPATH = $(patsubst %/,%,$(dir $(realpath "$(MAKE_PATH)/$(MAKE_FILENAME)")))
$(foreach VAR,MAKE_FILENAME MAKE_PATH MAKE_REALPATH,$(call make-lazy,$(VAR)))

MAKE_SELF_FILENAME = $(shell basename $(lastword $(MAKEFILE_LIST)))
MAKE_SELF_PATH := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

TOP ?= $(MAKE_PATH)
TOP_REL = $(shell python -c "import os.path; print('%s' % os.path.relpath('$(TOP)', '$(MAKE_PATH)'))")
$(foreach VAR,TOP_REL,$(call make-lazy,$(VAR)))

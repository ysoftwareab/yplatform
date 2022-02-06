CP_NOSYM = $(CP) -L
DIFF_SS = $(DIFF) -y -W $(COLUMNS)
EDITOR ?= $(call which,VI,vi)
FIND_Q = 2>/dev/null $(FIND)
FIND_Q_NOSYM = $(FIND_Q) -L
GREP_FILENAME = $(GREP) -rl
LS_ALL = $(LS) -A
$(foreach VAR,CP_NOSYM EDITOR FIND_Q FIND_Q_NOSYM GREP_FILENAME LS_ALL,$(call make-lazy,$(VAR)))
$(foreach VAR,DIFF_SS,$(call make-lazy-once,$(VAR)))

CURL = $(call which,CURL,curl) -qfsSL
JD = $(call which,JD,jd)
JQ = $(call which,JQ,jq)
YQ = $(call which,YQ,yq)
$(foreach VAR,CURL JD JQ YQ,$(call make-lazy,$(VAR)))

GIT = $(call which,GIT,git)
GIT_LS = $(GIT) ls-files
GIT_LS_NEW = $(GIT_LS) --others --directory --no-empty-directory
GIT_LS_SUB = $(CAT) .gitmodules | $(GREP) "path =" | $(SED) "s/.\{0,\}path = //"
$(foreach VAR,GIT GIT_LS GIT_LS_NEW GIT_LS_SUB,$(call make-lazy,$(VAR)))

PATCH_STDOUT = $(PATCH) -o -
UNZIP = $(call which,UNZIP,unzip) -oq
VISUAL ?= $(EDITOR)
ZIP_NOSYM = $(call which,ZIP_NOSYM,zip) -r
ZIP = $(ZIP_NOSYM) -y
ZIPINFO = $(call which,ZIPINFO,zipinfo)
$(foreach VAR,PATCH_STDOUT UNZIP VISUAL ZIP_NOSYM ZIP ZIPINFO,$(call make-lazy,$(VAR)))

ifneq (,$(wildcard .tool-version))
ifndef ASDF_BIN
ASDF_BIN := $(shell $(YP_DIR)/bin/asdf-get-asdf-bin)
endif
ifneq (,$(ASDF_BIN))
ifeq (,$(findstring :$(ASDF_BIN):,:$(PATH):))
export ASDF_BIN
export PATH := $(ASDF_BIN):$(PATH)
endif
endif
endif

ifneq (,$(wildcard .nvmrc))
ifndef NVM_BIN
NVM_BIN := $(shell $(YP_DIR)/bin/nvm-get-nvm-bin)
endif
ifneq (,$(NVM_BIN))
ifeq (,$(findstring :$(NVM_BIN):,:$(PATH):))
export NVM_BIN
export PATH := $(NVM_BIN):$(PATH)
endif
endif
endif

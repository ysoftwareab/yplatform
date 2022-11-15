# WARNING: DO NOT EDIT. AUTO-GENERATED CODE (mk/common.inc.dist.mk.tpl)
# ------------------------------------------------------------------------------

ifdef INSTALL_CORE_INC_MK
else

ifndef CORE_INC_MK_DIR
CORE_INC_MK_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))
endif

# defined here for consistency, later defined properly in exe.gnu.inc.mk
DATE := date
ECHO := echo
GREP := grep
PYTHON := python


# ------------------------------------------------------------------------------
# include $(CORE_INC_MK_DIR)/chars.inc.mk
# BEGIN chars.inc.mk
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
# END chars.inc.mk
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# include $(CORE_INC_MK_DIR)/core.inc.mk
# BEGIN core.inc.mk
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
# END core.inc.mk
# ------------------------------------------------------------------------------



# ------------------------------------------------------------------------------
# include $(CORE_INC_MK_DIR)/exe.inc.mk
# BEGIN exe.inc.mk

# ------------------------------------------------------------------------------
# include $(CORE_INC_MK_DIR)/exe.which.inc.mk
# BEGIN exe.which.inc.mk
# WHICH_Q is kept for backward compatibility
WHICH_Q := 2>/dev/null which
COMMAND_Q := 2>/dev/null command -v

# NOTE can't use $(ECHO)
define global-which
$(shell \
	hash -r; \
	export RESULT="$$(for CMD in $(2); do $(COMMAND_Q) $${CMD} && break || continue; done)"; \
	echo "$${RESULT:-$(1)_NOT_FOUND}")
endef

# NOTE can't use $(ECHO)
define which
$(shell \
	export PATH="$(PATH)"; \
	hash -r; \
	export RESULT="$$(for CMD in $(2); do $(COMMAND_Q) $${CMD} && break || continue; done)"; \
	echo "$${RESULT:-$(1)_NOT_FOUND}")
endef
# END exe.which.inc.mk
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# include $(CORE_INC_MK_DIR)/exe.gnu.inc.mk
# BEGIN exe.gnu.inc.mk
# the g-prefixed commands are supposed to cater for MacOS (i.e. homebrew, etc)

# coreutils: generated by
# ls $(brew --prefix coreutils)/libexec/gnubin | grep -v '^\[$' | while read -r VAR; do VAR_UPPER="$(echo "$VAR" | tr "[:lower:]" "[:upper:]")"; echo "$VAR_UPPER = \$(call which,${VAR_UPPER},g$VAR $VAR)"; done # editorconfig-checker-disable-line

B2SUM = $(call which,B2SUM,gb2sum b2sum)
BASE32 = $(call which,BASE32,gbase32 base32)
BASE64 = $(call which,BASE64,gbase64 base64)
BASENAME = $(call which,BASENAME,gbasename basename)
BASENC = $(call which,BASENC,gbasenc basenc)
CAT = $(call which,CAT,gcat cat)
CHCON = $(call which,CHCON,gchcon chcon)
CHGRP = $(call which,CHGRP,gchgrp chgrp)
CHMOD = $(call which,CHMOD,gchmod chmod)
CHOWN = $(call which,CHOWN,gchown chown)
CHROOT = $(call which,CHROOT,gchroot chroot)
CKSUM = $(call which,CKSUM,gcksum cksum)
COMM = $(call which,COMM,gcomm comm)
CP = $(call which,CP,gcp cp)
CSPLIT = $(call which,CSPLIT,gcsplit csplit)
CUT = $(call which,CUT,gcut cut)
DATE = $(call which,DATE,gdate date)
DD = $(call which,DD,gdd dd)
DF = $(call which,DF,gdf df)
DIR = $(call which,DIR,gdir dir)
DIRCOLORS = $(call which,DIRCOLORS,gdircolors dircolors)
DIRNAME = $(call which,DIRNAME,gdirname dirname)
DU = $(call which,DU,gdu du)
ECHO = $(call which,ECHO,gecho echo)
ENV = $(call which,ENV,genv env)
EXPAND = $(call which,EXPAND,gexpand expand)
EXPR = $(call which,EXPR,gexpr expr)
FACTOR = $(call which,FACTOR,gfactor factor)
FALSE = $(call which,FALSE,gfalse false)
FMT = $(call which,FMT,gfmt fmt)
FOLD = $(call which,FOLD,gfold fold)
GROUPS = $(call which,GROUPS,ggroups groups)
HEAD = $(call which,HEAD,ghead head)
HOSTID = $(call which,HOSTID,ghostid hostid)
ID = $(call which,ID,gid id)
INSTALL = $(call which,INSTALL,ginstall install)
JOIN = $(call which,JOIN,gjoin join)
KILL = $(call which,KILL,gkill kill)
LINK = $(call which,LINK,glink link)
LN = $(call which,LN,gln ln)
LS = $(call which,LS,gls ls)
MD5SUM = $(call which,MD5SUM,gmd5sum md5sum)
MKDIR = $(call which,MKDIR,gmkdir mkdir)
MKFIFO = $(call which,MKFIFO,gmkfifo mkfifo)
MKNOD = $(call which,MKNOD,gmknod mknod)
MKTEMP = $(call which,MKTEMP,gmktemp mktemp)
MV = $(call which,MV,gmv mv)
NICE = $(call which,NICE,gnice nice)
NL = $(call which,NL,gnl nl)
NOHUP = $(call which,NOHUP,gnohup nohup)
NPROC = $(call which,NPROC,gnproc nproc)
NUMFMT = $(call which,NUMFMT,gnumfmt numfmt)
OD = $(call which,OD,god od)
PASTE = $(call which,PASTE,gpaste paste)
PATHCHK = $(call which,PATHCHK,gpathchk pathchk)
PINKY = $(call which,PINKY,gpinky pinky)
PR = $(call which,PR,gpr pr)
PRINTENV = $(call which,PRINTENV,gprintenv printenv)
PRINTF = $(call which,PRINTF,gprintf printf)
PTX = $(call which,PTX,gptx ptx)
READLINK = $(call which,READLINK,greadlink readlink)
REALPATH = $(call which,REALPATH,grealpath realpath)
RM = $(call which,RM,grm rm)
RMDIR = $(call which,RMDIR,grmdir rmdir)
RUNCON = $(call which,RUNCON,gruncon runcon)
SEQ = $(call which,SEQ,gseq seq)
SHA1SUM = $(call which,SHA1SUM,gsha1sum sha1sum)
SHA224SUM = $(call which,SHA224SUM,gsha224sum sha224sum)
SHA256SUM = $(call which,SHA256SUM,gsha256sum sha256sum)
SHA384SUM = $(call which,SHA384SUM,gsha384sum sha384sum)
SHA512SUM = $(call which,SHA512SUM,gsha512sum sha512sum)
SHRED = $(call which,SHRED,gshred shred)
SHUF = $(call which,SHUF,gshuf shuf)
SLEEP = $(call which,SLEEP,gsleep sleep)
SORT = $(call which,SORT,gsort sort)
SPLIT = $(call which,SPLIT,gsplit split)
STAT = $(call which,STAT,gstat stat)
STDBUF = $(call which,STDBUF,gstdbuf stdbuf)
STTY = $(call which,STTY,gstty stty)
SUM = $(call which,SUM,gsum sum)
SYNC = $(call which,SYNC,gsync sync)
TAC = $(call which,TAC,gtac tac)
TAIL = $(call which,TAIL,gtail tail)
TEE = $(call which,TEE,gtee tee)
TEST = $(call which,TEST,gtest test)
TIMEOUT = $(call which,TIMEOUT,gtimeout timeout)
TOUCH = $(call which,TOUCH,gtouch touch)
TR = $(call which,TR,gtr tr)
TRUE = $(call which,TRUE,gtrue true)
TRUNCATE = $(call which,TRUNCATE,gtruncate truncate)
TSORT = $(call which,TSORT,gtsort tsort)
TTY = $(call which,TTY,gtty tty)
UNAME = $(call which,UNAME,guname uname)
UNEXPAND = $(call which,UNEXPAND,gunexpand unexpand)
UNIQ = $(call which,UNIQ,guniq uniq)
UNLINK = $(call which,UNLINK,gunlink unlink)
UPTIME = $(call which,UPTIME,guptime uptime)
USERS = $(call which,USERS,gusers users)
VDIR = $(call which,VDIR,gvdir vdir)
WC = $(call which,WC,gwc wc)
WHO = $(call which,WHO,gwho who)
WHOAMI = $(call which,WHOAMI,gwhoami whoami)
YES = $(call which,YES,gyes yes)

# coreutils: custom

CP = $(call which,CP,gcp cp) -Rp
LN = $(call which,LN,gln ln) -fn
MKDIR = $(call which,MKDIR,gmkdir mkdir) -p
MKTEMP = $(call which,MKTEMP,gmktemp mktemp) -t yplatform.XXXXXXXXXX
MV = $(call which,MV,gmv mv) -f
PARALLEL = $(call which,PARALLEL,gparallel parallel) --will-cite
RM = $(call which,RM,grm rm) -rf
XARGS = $(call which,XARGS,gxargs xargs) -r

# coreutils: make lazy. generated by
# echo "\$(foreach VAR,$(ls $(brew --prefix coreutils)/libexec/gnubin | grep -v -e '^\[$' -e '^logname$' -e '^pwd$' | tr '[:lower:]' '[:upper:]' | tr '\n' ' '),\$(call make-lazy,\$(VAR)))" # editorconfig-checker-disable-line
# ignoring [
# ignore logname - creates a LOGNAME var, sometimes exported, which should be =$USER (username), not a path
# ignore pwd - creates a PWD var, sometimes exported, which should be working dir not a path

$(foreach VAR,B2SUM BASE32 BASE64 BASENAME BASENC CAT CHCON CHGRP CHMOD CHOWN CHROOT CKSUM COMM CP CSPLIT CUT DATE DD DF DIR DIRCOLORS DIRNAME DU ECHO ENV EXPAND EXPR FACTOR FALSE FMT FOLD GROUPS HEAD HOSTID ID INSTALL JOIN KILL LINK LN LS MD5SUM MKDIR MKFIFO MKNOD MKTEMP MV NICE NL NOHUP NPROC NUMFMT OD PASTE PATHCHK PINKY PR PRINTENV PRINTF PTX READLINK REALPATH RM RMDIR RUNCON SEQ SHA1SUM SHA224SUM SHA256SUM SHA384SUM SHA512SUM SHRED SHUF SLEEP SORT SPLIT STAT STDBUF STTY SUM SYNC TAC TAIL TEE TEST TIMEOUT TOUCH TR TRUE TRUNCATE TSORT TTY UNAME UNEXPAND UNIQ UNLINK UPTIME USERS VDIR WC WHO WHOAMI YES ,$(call make-lazy,$(VAR))) # editorconfig-checker-disable-line

# ------------------------------------------------------------------------------

GNU_LOGNAME = $(call which,LOGNAME,glogname logname)
GNU_PWD = $(call which,LOGNAME,gpwd pwd)

$(foreach VAR,GNU_LOGNAME GNU_PWD,$(call make-lazy,$(VAR))) # editorconfig-checker-disable-line

# ------------------------------------------------------------------------------

# bash
BASH = $(call which,BASH,bash)
$(foreach VAR,BASH,$(call make-lazy,$(VAR))) # editorconfig-checker-disable-line

# ------------------------------------------------------------------------------

# diffutils
CMP = $(call which,CMP,gcmp cmp)
DIFF = $(call which,DIFF,gdiff diff)
DIFF3 = $(call which,DIFF3,gdiff3 diff3)
SDIFF = $(call which,SDIFF,gsdiff sdiff)
$(foreach VAR,CMP DIFF DIFF3 SDIFF,$(call make-lazy,$(VAR))) # editorconfig-checker-disable-line

# findutils
FIND = $(call which,FIND,gfind find)
LOCATE = $(call which,LOCATE,glocate locate)
UPDATEDB = $(call which,UPDATEDB,gupdatedb updatedb)
XARGS = $(call which,XARGS,gxargs xargs)
$(foreach VAR,FIND LOCATE UPDATEDB XARGS,$(call make-lazy,$(VAR))) # editorconfig-checker-disable-line

# gawk
AWK = $(call which,AWK,gawk awk)
$(foreach VAR,AWK,$(call make-lazy,$(VAR))) # editorconfig-checker-disable-line

# gettext
ENVSUBST = $(call which,ENVSUBST,envsubst)
$(foreach VAR,ENVSUBST,$(call make-lazy,$(VAR))) # editorconfig-checker-disable-line

# grep
EGREP = $(call which,EGREP,gegrep egrep)
FGREP = $(call which,FGREP,gfgrep fgrep)
GREP = $(call which,GREP,ggrep grep)
$(foreach VAR,EGREP FGREP GREP,$(call make-lazy,$(VAR))) # editorconfig-checker-disable-line

# gnu-sed
SED = $(call which,SED,gsed sed)
$(foreach VAR,SED,$(call make-lazy,$(VAR))) # editorconfig-checker-disable-line

# gnu-tar
TAR = $(call which,TAR,gtar tar)
$(foreach VAR,TAR,$(call make-lazy,$(VAR))) # editorconfig-checker-disable-line

# patch
PATCH = $(call which,PATCH,gpatch patch)
$(foreach VAR,PATCH,$(call make-lazy,$(VAR))) # editorconfig-checker-disable-line

# watch
WATCH = $(call which,WATCH,gwatch watch)
$(foreach VAR,WATCH,$(call make-lazy,$(VAR))) # editorconfig-checker-disable-line
# END exe.gnu.inc.mk
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# include $(CORE_INC_MK_DIR)/exe.echo.inc.mk
# BEGIN exe.echo.inc.mk
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
# END exe.echo.inc.mk
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# include $(CORE_INC_MK_DIR)/exe.misc.inc.mk
# BEGIN exe.misc.inc.mk
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
# END exe.misc.inc.mk
# ------------------------------------------------------------------------------

# END exe.inc.mk
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# include $(CORE_INC_MK_DIR)/os.inc.mk
# BEGIN os.inc.mk
ARCH = $(shell $(UNAME) -m)
# https://github.com/containerd/containerd/blob/f2c3122e9c6470c052318497899b290a5afc74a5/platforms/platforms.go#L88-L94
# https://github.com/BretFisher/multi-platform-docker-build
ARCH_NORMALIZED = $(shell $(ECHO) $(ARCH) | $(SED) \
	-e "s|^aarch64$$|arm64|" \
	-e "s|^arm64/v8$$|arm64|" \
	-e "s|^armhf$$|arm|" \
	-e "s|^arm64/v7$$|arm|" \
	-e "s|^armel$$|arm/v6|" \
	-e "s|^i386$$|386|" \
	-e "s|^i686$$|386|" \
	-e "s|^x86_64$$|amd64|" \
	-e "s|^x86-64$$|amd64|" \
)
ARCH_SHORT = $(shell $(ECHO) $(ARCH) | $(GREP) -q "64" && $(ECHO) "x64" || $(ECHO) "x86")
ARCH_BIT = $(shell $(ECHO) $(ARCH) | $(GREP) -q "64" && $(ECHO) "64" || $(ECHO) "32")
$(foreach VAR,ARCH ARCH_NORMALIZED ARCH_SHORT ARCH_BIT,$(call make-lazy,$(VAR)))

OS = $(shell $(UNAME) | $(TR) "[:upper:]" "[:lower:]")
OS_SHORT = $(shell $(ECHO) $(OS) | $(SED) "s/^\([[:alpha:]]\{1,\}\).*\$$/\1/g")
$(foreach VAR,OS OS_SHORT,$(call make-lazy,$(VAR)))
# END os.inc.mk
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# include $(CORE_INC_MK_DIR)/git.inc.mk
# BEGIN git.inc.mk
# sync with  sh/git.inc.sh

GIT_DIR = $(shell $(GIT) rev-parse --git-dir 2>/dev/null)
GIT_BRANCH = $(shell $(GIT) rev-parse --abbrev-ref HEAD 2>/dev/null)
GIT_BRANCH_SHORT = $(notdir $(GIT_BRANCH))
GIT_COMMIT_MSG = $(shell $(GIT) log -1 --format="%B" 2>/dev/null)
GIT_DESCRIBE = $(shell $(GIT) describe --tags --first-parent --always --dirty 2>/dev/null)
GIT_HASH = $(shell $(GIT) rev-parse HEAD 2>/dev/null)
GIT_HASH_SHORT = $(shell $(GIT) rev-parse --short HEAD 2>/dev/null)
GIT_TAGS = $(shell $(GIT) tag --points-at HEAD 2>/dev/null)

ifdef SEMAPHORE_GIT_BRANCH
GIT_BRANCH = $(SEMAPHORE_GIT_BRANCH)
endif

ifdef TRAVIS_BRANCH
GIT_BRANCH = $(TRAVIS_BRANCH)
endif

GIT_REMOTE = $(shell $(GIT) config branch.$(GIT_BRANCH).remote 2>/dev/null)
GIT_REMOTE_OR_ORIGIN = $(shell $(GIT) config branch.$(GIT_BRANCH).remote 2>/dev/null | \
	$(YP_DIR)/bin/ifne -p -n "$(ECHO) origin")
GIT_ROOT = $(shell $(GIT) rev-parse --show-toplevel 2>/dev/null)
$(foreach VAR,GIT_REMOTE GIT_REMOTE_OR_ORIGIN GIT_ROOT,$(call make-lazy-once,$(VAR)))

GIT_REPO_HAS_CHANGED_FILES = $(shell $(GIT) status --porcelain | $(GREP) -q -v -e "^$$" && \
	$(ECHO) true || $(ECHO) false)
GIT_REPO_HAS_STAGED_FILES = $(shell $(GIT) status --porcelain | $(GREP) -q -e "^[^ U\?]" && \
	$(ECHO) true || $(ECHO) false)
GIT_REPO_HAS_UNSTAGED_FILES = $(shell $(GIT) status --porcelain | $(GREP) -q -e "^ [^ ]" && \
	$(ECHO) true || $(ECHO) false)
GIT_REPO_HAS_UNTRACKED_FILES = $(shell $(GIT) status --porcelain | $(GREP) -q -e "^?\?" && \
	$(ECHO) true || $(ECHO) false)
GIT_REPO_HAS_CONFLICTS = $(shell $(GIT) status --porcelain | $(GREP) -q -e "^\(DD\|AU\|UD\|UA\|DU\|AA\|UU\)" && \
	$(ECHO) true || $(ECHO) false)
# END git.inc.mk
# ------------------------------------------------------------------------------



# ------------------------------------------------------------------------------
# include $(CORE_INC_MK_DIR)/target.env.inc.mk
# BEGIN target.env.inc.mk
.PHONY: guard-env-%
guard-env-%: # Guard on environment variable.
	@if [ "$($*)" = "" ] && [ "$${$*:-}" = "" ]; then \
		$(ECHO) >&2 "ERROR: Environment variable $* is not defined!"; \
		exit 1; \
	fi


.PHONY: guard-env-has-%
guard-env-has-%: # Guard on environment executable.
	@command -v "${*}" >/dev/null 2>&1 || { \
		$(ECHO) >&2 "ERROR: Please install ${*}!"; \
		exit 1; \
	}
# END target.env.inc.mk
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# include $(CORE_INC_MK_DIR)/target.help.inc.mk
# BEGIN target.help.inc.mk
HEXDUMP = $(call which,HEXDUMP,hexdump)
COLUMN = $(call which,COLUMN,column)

.PHONY: help
help: ## Show this help message.
	$(eval RANDOM_MARKER := $(shell $(HEXDUMP) -n 16 -e '4/4 "%08X" 1 "\n"' /dev/random))
	@$(ECHO) "usage: $(MAKE:$(firstword $(MAKE))=$$(basename $(firstword $(MAKE)))) [targets]"
	@$(ECHO)
	@$(ECHO) "Available targets:"
	@for Makefile in $(MAKEFILE_LIST); do \
		$(CAT) $${Makefile} | \
		$(SED) "s|^\([^#.\$$\t][^=]\{1,\}\):[^=]\{0,\}[[:space:]]##[[:space:]]\{1,\}\(.\{1,\}\)\$$|$(RANDOM_MARKER)  \1##\2|g"; \
	done | \
		$(GREP) "^$(RANDOM_MARKER)" | \
		$(SED) "s|^$(RANDOM_MARKER)||g" | \
		$(SORT) -u | \
		$(COLUMN) -t -s "##"


.PHONY: help-all
help-all: ## Show this help message, including all intermediary targets and source Makefiles.
	$(eval RANDOM_MARKER := $(shell $(HEXDUMP) -n 16 -e '4/4 "%08X" 1 "\n"' /dev/random))
	@$(ECHO) "usage: $(MAKE:$(firstword $(MAKE))=$$(basename $(firstword $(MAKE)))) [targets]"
	@$(ECHO)
	@$(ECHO) "Available targets:"
	@for Makefile in $(MAKEFILE_LIST); do \
		$(CAT) $${Makefile} | \
		$(SED) "s|^\([^#.\$$\t][^=]\{1,\}\):[^=]\{0,\}\$$|$(RANDOM_MARKER)  \1##$${Makefile#$(MAKE_PATH)/}##|g" | \
		$(SED) "s|^\([^#.\$$\t][^=]\{1,\}\):[^=]\{0,\}\([[:space:]]##[[:space:]]\{1,\}\(.\{1,\}\)\)\?\$$|$(RANDOM_MARKER)  \1##$${Makefile#$(MAKE_PATH)/}##\3|g"; \
	done | \
		$(GREP) "^$(RANDOM_MARKER)" | \
		$(SED) "s|^$(RANDOM_MARKER)||g" | \
		$(SORT) -u | \
		$(COLUMN) -t -s "##"
# END target.help.inc.mk
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# include $(CORE_INC_MK_DIR)/target.noop.inc.mk
# BEGIN target.noop.inc.mk
# noop TARGET
# Usage:
# my-target: my-optional-target | noop
.PHONY: noop
noop:
	@:

# noop/% TARGET
# Usage:
# my-target: noop/my-optional-target
.PHONY: noop/%
noop/%:
	@:

# skip/% TARGET, alias to noop/%
# Usage:
# my-target: skip/my-optional-target
.PHONY: skip/%
skip/%:
	@:
# END target.noop.inc.mk
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# include $(CORE_INC_MK_DIR)/target.printvar.inc.mk
# BEGIN target.printvar.inc.mk
# see https://blog.melski.net/2010/11/30/makefile-hacks-print-the-value-of-any-variable/

# see https://www.gnu.org/software/make/manual/html_node/Origin-Function.html
MAKEFILE_ORIGINS := \
	default \
	environment \
	environment\ override \
	file \
	command\ line \
	override \
	automatic \
	\%

PRINTVARS_MAKEFILE_ORIGINS_TARGETS += \
	$(patsubst %,printvars/%,$(MAKEFILE_ORIGINS)) \

# ------------------------------------------------------------------------------

.PHONY: printvars
printvars: printvars/file ## Print all Makefile variables (file origin).


.PHONY: $(PRINTVARS_MAKEFILE_ORIGINS_TARGETS)
$(PRINTVARS_MAKEFILE_ORIGINS_TARGETS):
	@$(foreach V, $(sort $(filter-out $(PRINTVARS_VARIABLES_IGNORE),$(.VARIABLES))), \
		$(if $(filter $(@:printvars/%=%), $(origin $V)), \
			$(warning $V=$($V) ($(value $V))))))


.PHONY: printvars/lazy
printvars/lazy:
	@$(foreach V, $(sort $(.VARIABLES_LAZY)), \
		$(warning $V=$($V)))


.PHONY: printvar-%
printvar-%: ## Print one Makefile variable.
	@$(ECHO) $*=$($*)
	@$(ECHO) '  origin = $(origin $*)'
	@$(ECHO) '  flavor = $(flavor $*)'
	@$(ECHO) '   value = $(value  $*)'
# END target.printvar.inc.mk
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# include $(CORE_INC_MK_DIR)/target.verbose.inc.mk
# BEGIN target.verbose.inc.mk
# useful internally as
# YP_DEPS_TARGETS := $(subst deps-npm,verbose/deps-npm,$(YP_DEPS_TARGETS))

.PHONY: verbose/%
verbose/%: ## Run a target with verbosity on (VERBOSE=1 or V=1).
	@$(MAKE) V=1 $*
# END target.verbose.inc.mk
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# include $(CORE_INC_MK_DIR)/target.lazy.inc.mk
# BEGIN target.lazy.inc.mk
Makefile.lazy:
	@$(foreach V, $(sort $(.VARIABLES_LAZY)), \
		$(ECHO) "$V:=$(subst ",\",$($V))" >> $@;)
# END target.lazy.inc.mk
# ------------------------------------------------------------------------------


MAKEFILE_LAZY ?= true
ifeq (true,$(MAKEFILE_LAZY))
ifeq ($(MAKECMDGOALS),$(filter-out %Makefile.lazy,$(MAKECMDGOALS)))
ifeq (,$(wildcard Makefile.lazy))
$(info [DO  ] Generating Makefile.lazy...)
$(info $(shell $(MAKE) Makefile.lazy))
$(info [DONE])
$(info )
endif
include Makefile.lazy
endif
endif

INSTALL_CORE_INC_MK := 1
endif

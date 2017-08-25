CP_NOSYM = $(CP) -L
DIFF_SS = $(DIFF) -y -W $(COLUMNS)
FIND_Q = 2>/dev/null $(FIND)
FIND_Q_NOSYM = $(FIND_Q) -L
GREP_FILENAME = $(GREP) -rl
LS_ALL = $(LS) -A
$(foreach VAR,CP_NOSYM DIFF_SS FIND_Q FIND_Q_NOSYM GREP_FILENAME LS_ALL,$(call make-lazy,$(VAR)))

CURL = $(call which,CURL,curl) -qsS
JQ = $(call which,JQ,jq)
JSON = $(call which,JSON,json) -D " " # to allow / or . in a key
$(foreach VAR,CURL JQ JSON,$(call make-lazy,$(VAR)))

GIT = $(call which,GIT,git)
GIT_LS = $(GIT) ls-files
GIT_LS_NEW = $(GIT_LS) --exclude-standard --others --ignored --directory --no-empty-directory
GIT_LS_SUB = $(CAT) .gitmodules | $(GREP) "path =" | $(SED) "s/.*path = //"
$(foreach VAR,GIT GIT_LS GIT_LS_NEW GIT_LS_SUB,$(call make-lazy,$(VAR)))

ZIP_NOSYM = $(call which,ZIP_NOSYM,zip) -r
ZIP = $(ZIP_NOSYM) -y
UNZIP = $(call which,UNZIP,unzip) -oq
ZIPINFO = $(call which,ZIPINFO,zipinfo)
$(foreach VAR,ZIP_NOSYM ZIP UNZIP ZIPINFO,$(call make-lazy,$(VAR)))

BABEL = $(call which,BABEL,babel)
NODE = $(call which,NODE,node)
NODE_BABEL = $(NODE) -r babel-register
NODE_NPM = $(shell realpath $(NODE) | $(SED) "s/bin\/node\$$/libexec\/npm\/bin\/npm/")
NPM = $(call which,NPM,npm)
$(foreach VAR,BABEL NODE NODE_BABEL NODE_NPM NPM,$(call make-lazy,$(VAR)))

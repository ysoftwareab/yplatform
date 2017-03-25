CP_NOSYM = $(CP) -L
DIFF_SS = $(DIFF) -y -W $(COLUMNS)
FIND_Q = 2>/dev/null $(FIND)
FIND_Q_NOSYM = $(FIND_Q) -L
GREP_FILENAME = $(GREP) -rl
LS_ALL = $(LS) -A
$(foreach VAR,CP_NOSYM DIFF_SS FIND_Q FIND_Q_NOSYM GREP_FILENAME LS_ALL,$(call make-lazy,$(VAR)))

CURL = $(shell $(WHICH_Q) curl || echo "CURL_NOT_FOUND") -qsS
KATT ?= $(shell $(WHICH_Q) katt || echo "KATT_NOT_FOUND")
$(foreach VAR,CURL KATT,$(call make-lazy,$(VAR)))

JQ = $(shell $(WHICH_Q) jq || echo "JQ_NOT_FOUND")
JSON ?= $(shell $(WHICH_Q) json || echo "JSON_NOT_FOUND") -D " " # to allow / or . in a key
$(foreach VAR,JQ JSON,$(call make-lazy,$(VAR)))

PYTHON = $(shell $(WHICH_Q) python || echo "PYTHON_NOT_FOUND")
$(foreach VAR,PYTHON,$(call make-lazy,$(VAR)))

DOT = $(shell $(WHICH_Q) dot || echo "GRAPHVIZ_DOT_NOT_FOUND")
SPONGE ?= $(shell $(WHICH_Q) sponge || echo "SPONGE_NOT_FOUND")
$(foreach VAR,DOT SPONGE,$(call make-lazy,$(VAR)))

GIT = $(shell $(WHICH_Q) git || echo "GIT_NOT_FOUND")
GIT_LS_NEW = $(GIT) ls-files --exclude-standard --others --ignored --directory --no-empty-directory
GIT_LS_SUB = $(CAT) .gitmodules | $(GREP) "path =" | $(SED) "s/.*path = //"
$(foreach VAR,GIT GIT_LS_NEW GIT_LS_SUB,$(call make-lazy,$(VAR)))

ZIP_NOSYM = $(shell $(WHICH_Q) zip || echo "ZIP_NOT_FOUND") -r
ZIP = $(ZIP_NOSYM) -y
UNZIP = $(shell $(WHICH_Q) unzip || echo "UNZIP_NOT_FOUND") -oq
ZIPINFO = $(shell $(WHICH_Q) zipinfo || echo "ZIPINFO_NOT_FOUND")
$(foreach VAR,ZIP_NOSYM ZIP UNZIP ZIPINFO,$(call make-lazy,$(VAR)))

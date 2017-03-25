# the g-prefixed commands are supposed to cater for Mac OSX (i.e. homebrew, etc)

AWK = $(shell $(WHICH_Q) gawk || $(WHICH_Q) awk || echo "GNU_AWK_NOT_FOUND")
BASENAME = $(shell $(WHICH_Q) gbasename || $(WHICH_Q) basename || echo "GNU_BASENAME_NOT_FOUND")
CAT = $(shell $(WHICH_Q) gcat || $(WHICH_Q) cat || echo "GNU_CAT_NOT_FOUND")
CHMOD = $(shell $(WHICH_Q) gchmod || $(WHICH_Q) chmod || echo "GNU_CHMOD_NOT_FOUND")
CHOWN = $(shell $(WHICH_Q) gchown || $(WHICH_Q) chown || echo "GNU_CHOWN_NOT_FOUND")
COMM = $(shell $(WHICH_Q) gcomm || $(WHICH_Q) comm || echo "GNU_COMM_NOT_FOUND")
CP = $(shell $(WHICH_Q) gcp || $(WHICH_Q) cp || echo "GNU_CP_NOT_FOUND") -Rp
CUT = $(shell $(WHICH_Q) gcut || $(WHICH_Q) cut || echo "GNU_CUT_NOT_FOUND")
DIFF = $(shell $(WHICH_Q) gdiff || $(WHICH_Q) diff || echo "GNU_DIFF_NOT_FOUND")
FIND = $(shell $(WHICH_Q) gfind || $(WHICH_Q) find || echo "GNU_FIND_NOT_FOUND")
ECHO = $(shell $(WHICH_Q) gecho || $(WHICH_Q) echo || echo "GNU_ECHO_NOT_FOUND")
GREP = $(shell $(WHICH_Q) ggrep || $(WHICH_Q) gnugrep || $(WHICH_Q) grep || echo "GNU_GREP_NOT_FOUND")
HEAD = $(shell $(WHICH_Q) ghead || $(WHICH_Q) head || echo "GNU_HEAD_NOT_FOUND")
LS = $(shell $(WHICH_Q) gls || $(WHICH_Q) ls || echo "GNU_LS_NOT_FOUND")
MD5SUM = $(shell $(WHICH_Q) gmd5sum || $(WHICH_Q) md5sum || echo "GNU_MD5SUM_NOT_FOUND")
MKDIR = $(shell $(WHICH_Q) gmkdir || $(WHICH_Q) mkdir || echo "GNU_MKDIR_NOT_FOUND") -p
MKTEMP = $(shell $(WHICH_Q) gmktemp || $(WHICH_Q) mktemp || echo "GNU_MKTEMP_NOT_FOUND") -t firecloud.XXXXXXXXXX
MV = $(shell $(WHICH_Q) gmv || $(WHICH_Q) mv || echo "GNU_MV_NOT_FOUND") -f
PARALLEL = $(shell $(WHICH_Q) gparallel || $(WHICH_Q) parallel || echo "GNU_PARALLEL_NOT_FOUND") --will-cite
RM = $(shell $(WHICH_Q) grm || $(WHICH_Q) rm || echo "GNU_RM_NOT_FOUND") -rf
SED = $(shell $(WHICH_Q) gsed || $(WHICH_Q) sed || echo "GNU_SED_NOT_FOUND")
SHA256SUM = $(shell $(WHICH_Q) gsha256sum || $(WHICH_Q) sha256sum || echo "GNU_SHA256SUM_NOT_FOUND")
SORT = $(shell $(WHICH_Q) gsort || $(WHICH_Q) sort || echo "GNU_SORT_NOT_FOUND")
TAIL = $(shell $(WHICH_Q) gtail || $(WHICH_Q) tail || echo "GNU_TAIL_NOT_FOUND")
TEE = $(shell $(WHICH_Q) gtee || $(WHICH_Q) tee || echo "GNU_TEE_NOT_FOUND")
TOUCH = $(shell $(WHICH_Q) gtouch || $(WHICH_Q) touch || echo "GNU_TOUCH_NOT_FOUND")
TR = $(shell $(WHICH_Q) gtr || $(WHICH_Q) tr || echo "GNU_TR_NOT_FOUND")
WATCH = $(shell $(WHICH_Q) gwatch || $(WHICH_Q) watch || echo "GNU_WATCH_NOT_FOUND")
XARGS = $(shell $(WHICH_Q) gxargs || $(WHICH_Q) xargs || echo "GNU_XARGS_NOT_FOUND")
$(foreach VAR,AWK BASENAME CAT CHMOD CHOWN COMM CP CUT DIFF FIND ECHO GREP HEAD LS MD5SUM MKDIR MKTEMP MV PARALLEL RM SED SHA256SUM SORT TAIL TEE TOUCH TR WATCH XARGS,$(call make-lazy,$(VAR)))

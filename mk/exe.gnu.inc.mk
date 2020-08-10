# the g-prefixed commands are supposed to cater for Mac OSX (i.e. homebrew, etc)

AWK = $(call which,AWK,gawk awk)
BASENAME = $(call which,BASENAME,gbasename basename)
CAT = $(call which,CAT,gcat cat)
CHMOD = $(call which,CHMOD,gchmod chmod)
CHOWN = $(call which,CHOWN,gchown chown)
COMM = $(call which,COMM,gcomm comm)
CP = $(call which,CP,gcp cp) -Rp
CUT = $(call which,CUT,gcut cut)
DATE = $(call which,DATE,gdate date)
DIFF = $(call which,DIFF,gdiff diff)
FIND = $(call which,FIND,gfind find)
ECHO = $(call which,ECHO,gecho echo)
EXPR = $(call which,EXPR,gexpr expr)
GREP = $(call which,GREP,ggrep grep)
$(foreach VAR,AWK BASENAME CAT CHMOD CHOWN COMM CP CUT DATE DIFF FIND ECHO GREP,$(call make-lazy,$(VAR)))

# ------------------------------------------------------------------------------

HEAD = $(call which,HEAD,ghead head)
LN = $(call which,LN,gln ln) -f
LS = $(call which,LS,gls ls)
MD5SUM = $(call which,MD5SUM,gmd5sum md5sum)
MKDIR = $(call which,MKDIR,gmkdir mkdir) -p
MKTEMP = $(call which,MKTEMP,gmktemp mktemp) -t core-inc-mk.XXXXXXXXXX
MV = $(call which,MV,gmv mv) -f
PATCH = $(call which,PATCH,gpatch patch)
PARALLEL = $(call which,PARALLEL,gparallel parallel) --will-cite
$(foreach VAR,HEAD LN LS MD5SUM MKDIR MKTEMP MV PATCH PARALLEL,$(call make-lazy,$(VAR)))

#-------------------------------------------------------------------------------

READLINK = $(call which,READLINK,greadlink readlink)
REALPATH = $(call which,REALPATH,grealpath realpath)
RM = $(call which,RM,grm rm) -rf
SED = $(call which,SED,gsed sed)
SEQ = $(call which,SEQ,gseq seq)
SHA256SUM = $(call which,SHA256SUM,gsha256sum sha256sum)
SORT = $(call which,SORT,gsort sort)
TAIL = $(call which,TAIL,gtail tail)
TAR = $(call which,TAR,gtar tar)
TEE = $(call which,TEE,gtee tee)
TEST = $(call which,TEST,gtest test)
TOUCH = $(call which,TOUCH,gtouch touch)
TR = $(call which,TR,gtr tr)
UNAME = $(call which,XARGS,guname uname)
WATCH = $(call which,WATCH,gwatch watch)
WC = $(call which,WC,gwc wc)
XARGS = $(call which,XARGS,gxargs xargs) -r
$(foreach VAR,READLINK REALPATH RM SED SEQ SHA256SUM SORT TAIL TAR TEE TOUCH TR UNAME WATCH WC XARGS,$(call make-lazy,$(VAR)))

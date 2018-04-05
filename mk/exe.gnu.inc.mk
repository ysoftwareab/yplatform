# the g-prefixed commands are supposed to cater for Mac OSX (i.e. homebrew, etc)

AWK = $(call which,AWK,gawk awk)
BASENAME = $(call which,BASENAME,gbasename basename)
CAT = $(call which,CAT,gcat cat)
CHMOD = $(call which,CHMOD,gchmod chmod)
CHOWN = $(call which,CHOWN,gchown chown)
COMM = $(call which,COMM,gcomm comm)
CP = $(call which,CP,gcp cp) -Rp
CUT = $(call which,CUT,gcut cut)
DIFF = $(call which,DIFF,gdiff diff)
FIND = $(call which,FIND,gfind find)
ECHO = $(call which,ECHO,gecho echo)
GREP = $(call which,GREP,ggrep grep)
HEAD = $(call which,HEAD,ghead head)
LS = $(call which,LS,gls ls)
MD5SUM = $(call which,MD5SUM,gmd5sum md5sum)
MKDIR = $(call which,MKDIR,gmkdir mkdir) -p
MKTEMP = $(call which,MKTEMP,gmktemp mktemp) -t core-inc-mk.XXXXXXXXXX
MV = $(call which,MV,gmv mv) -f
PARALLEL = $(call which,PARALLEL,gparallel parallel) --will-cite
REALPATH = $(call which,REALPATH,grealpath realpath)
RM = $(call which,RM,grm rm) -rf
SED = $(call which,SED,gsed sed)
SHA256SUM = $(call which,SHA256SUM,gsha256sum sha256sum)
SORT = $(call which,SORT,gsort sort)
TAR = $(call which,TAR,gtar tar)
TAIL = $(call which,TAIL,gtail tail)
TEE = $(call which,TEE,gtee tee)
TOUCH = $(call which,TOUCH,gtouch touch)
TR = $(call which,TR,gtr tr)
WATCH = $(call which,WATCH,gwatch watch)
XARGS = $(call which,XARGS,gxargs xargs)
$(foreach VAR,AWK BASENAME CAT CHMOD CHOWN COMM CP CUT DIFF FIND ECHO GREP HEAD LS MD5SUM MKDIR MKTEMP MV PARALLEL REALPATH RM SED SHA256SUM SORT TAR TAIL TEE TOUCH TR WATCH XARGS,$(call make-lazy,$(VAR)))

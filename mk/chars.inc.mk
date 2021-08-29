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

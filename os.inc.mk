OS = $(shell uname | tr "A-Z" "a-z")
OS_SHORT = $(shell echo $(OS) | sed "s/^\([a-z]\+\).*/\1/g")
$(foreach VAR,OS OS_SHORT,$(call make-lazy,$(VAR)))

ARCH = $(shell uname -m)
ARCH_SHORT = $(shell uname -m | grep -q "x86_64" && echo "x64" || echo "x86")
ARCH_BIT = $(shell uname -m | grep -q "x86_64" && echo "64" || echo "32")
$(foreach VAR,ARCH ARCH_SHORT ARCH_BIT,$(call make-lazy,$(VAR)))

ARCH = $(shell $(UNAME) -m)
ARCH_SHORT = $(shell $(UNAME) -m | grep -q "x86_64" && echo "x64" || echo "x86")
ARCH_BIT = $(shell $(UNAME) -m | grep -q "x86_64" && echo "64" || echo "32")
$(foreach VAR,ARCH ARCH_SHORT ARCH_BIT,$(call make-lazy,$(VAR)))

OS = $(shell $(UNAME) | $(TR) "[:upper:]" "[:lower:]")
OS_SHORT = $(shell $(ECHO) $(OS) | $(SED) "s/^\([[:alpha:]]\{1,\}\).*\$$/\1/g")
$(foreach VAR,OS OS_SHORT,$(call make-lazy,$(VAR)))

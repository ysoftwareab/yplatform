ARCH = $(shell $(UNAME) -m)
ARCH_SHORT = $(shell $(ECHO) $(ARCH) | grep -q "x86_64" && $(ECHO) "x64" || $(ECHO) "x86")
ARCH_BIT = $(shell $(ECHO) $(ARCH) | grep -q "x86_64" && $(ECHO) "64" || $(ECHO) "32")
$(foreach VAR,ARCH ARCH_SHORT ARCH_BIT,$(call make-lazy,$(VAR)))

OS = $(shell $(UNAME) | $(TR) "[:upper:]" "[:lower:]")
OS_SHORT = $(shell $(ECHO) $(OS) | $(SED) "s/^\([[:alpha:]]\{1,\}\).*\$$/\1/g")
$(foreach VAR,OS OS_SHORT,$(call make-lazy,$(VAR)))

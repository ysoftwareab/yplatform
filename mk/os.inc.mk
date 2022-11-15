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

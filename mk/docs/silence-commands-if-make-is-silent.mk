BASH_SILENT=
ifneq (,$(findstring "s",$(firstword -$(MAKEFLAGS))))
BASH_SILENT=" >/dev/null 2>&1"
endif

target:
	some command $(BASH_SILENT)

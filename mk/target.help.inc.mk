.PHONY: help
help: ## Show this help message.
	@echo "usage: `basename $(MAKE)` [targets]"
	@echo
	@echo "Available targets:"
	@for Makefile in $(MAKEFILE_LIST); do \
		$(SED) "s/^\([^#.$$\t][^=]\+\):[^=]*\s##\s\+\(.\+\)\$$/  \1##\2/;tx;d;:x" $${Makefile}; \
	done | sort -u | column -t -s "##"


.PHONY: help-all
help-all: ## Show this help message, including all intermediary targets and source Makefiles.
	@echo "usage: `basename $(MAKE)` [targets]"
	@echo
	@echo "Available targets:"
	@for Makefile in $(MAKEFILE_LIST); do \
		$(SED) "s|^\([^#.$$\t][^=]\+\):\([^=]*\s##\s\+\(.\+\)\)\?\$$|  \1##$${Makefile#$(SUPPORT_FIRECLOUD_DIR)/}##\3|;tx;d;:x" $${Makefile}; \
	done | sort -u | column -t -s "##"

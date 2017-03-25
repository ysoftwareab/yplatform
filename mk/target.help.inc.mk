.PHONY: help
help: ## Show this help message.
	@echo "usage: `basename $(MAKE)` [targets]"
	@echo
	@echo "Available targets:"
	@$(SED) "s/^\(.\+\):.*\s##\s\+\(.\+\)\$$/  \1##\2/;tx;d;:x" $(MAKEFILE_LIST) | sort -u | column -t -s "##"

.PHONY: printvars
printvars: ## Print all Makefile variables.
	@$(foreach V,$(sort $(.VARIABLES)), $(if $(filter-out environment% default automatic, $(origin $V)),$(warning $V=$($V) ($(value $V)))))


.PHONY: printvar-%
printvar-%: ## Print one Makefile variable.
	@echo $*=$($*)
	@echo '  origin = $(origin $*)'
	@echo '  flavor = $(flavor $*)'
	@echo '   value = $(value  $*)'

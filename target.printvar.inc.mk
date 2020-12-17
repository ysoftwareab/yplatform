# see https://blog.melski.net/2010/11/30/makefile-hacks-print-the-value-of-any-variable/

# see https://www.gnu.org/software/make/manual/html_node/Origin-Function.html
MAKEFILE_ORIGINS := \
	default \
	environment \
	environment\ override \
	file \
	command\ line \
	override \
	automatic \
	\%

PRINTVARS_MAKEFILE_ORIGINS_TARGETS += \
	$(patsubst %,printvars/%,$(MAKEFILE_ORIGINS)) \

# ------------------------------------------------------------------------------

.PHONY: printvars
printvars: printvars/file ## Print all Makefile variables (file origin).


.PHONY: $(PRINTVARS_MAKEFILE_ORIGINS_TARGETS)
$(PRINTVARS_MAKEFILE_ORIGINS_TARGETS):
	@$(foreach V, $(sort $(filter-out $(PRINTVARS_VARIABLES_IGNORE),$(.VARIABLES))), \
		$(if $(filter $(@:printvars/%=%), $(origin $V)), \
			$(warning $V=$($V) ($(value $V))))))


.PHONY: printvars/lazy
printvars/lazy:
	@$(foreach V, $(sort $(.VARIABLES_LAZY)), \
		$(warning $V=$($V)))


.PHONY: printvar-%
printvar-%: ## Print one Makefile variable.
	@echo $*=$($*)
	@echo '  origin = $(origin $*)'
	@echo '  flavor = $(flavor $*)'
	@echo '   value = $(value  $*)'

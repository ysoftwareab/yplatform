# FUNCTION
define my-fun
	@$(eval input := $<)
	@$(eval output := $@)
	@echo $(input) $(output) $(1)
endef

%.coffee: %.js
	$(my-fun "arg1")

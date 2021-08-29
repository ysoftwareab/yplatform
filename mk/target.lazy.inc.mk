Makefile.lazy:
	@$(foreach V, $(sort $(.VARIABLES_LAZY)), \
		$(ECHO) "$V:=$(subst ",\",$($V))" >> $@;)

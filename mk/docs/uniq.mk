# Uniq words in string
# From https://stackoverflow.com/a/16151140/465684
define uniq
$(eval SEEN :=)
$(foreach _,$1,$(if $(filter $_,$(SEEN)),,$(eval SEEN += $_)))
$(SEEN)
endef

# Adds a 'shell' target which starts a shell session from within the Makefile.
#
# Adds a 'shell/tmate' target which starts a remote shell session
# from within the Makefile using 'tmate'.
#
# ------------------------------------------------------------------------------

#	TODO Uncertain if tmate works without a pre-existing ~/.ssh/id_rsa
# SSH_KEYGEN = $(call which,SSH_KEYGEN,ssh-keygen)
# $(foreach VAR,SSH_KEYGEN,$(call make-lazy-once,$(VAR)))

TMATE = $(call which,TMATE,tmate)
$(foreach VAR,TMATE,$(call make-lazy-once,$(VAR)))

TMATE_SOCKET := $(shell $(MKTEMP))

# ------------------------------------------------------------------------------

.PHONY: shell
shell:
	$(SHELL)


.PHONY: shell/tmate
shell/tmate:
	$(YP_DIR)/bin/tmate-shell

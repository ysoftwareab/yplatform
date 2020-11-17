# Adds a 'shell' target which starts a shell session from within the Makefile.
#
# Adds a 'shell/tmate' target which starts a remote shell session
# from within the Makefile using 'tmate'.
#
# ------------------------------------------------------------------------------

TMATE = $(call which,TMATE,tmate)
$(foreach VAR,TMATE,$(call make-lazy,$(VAR)))

TMATE_SOCKET := $(shell $(MKTEMP))

# ------------------------------------------------------------------------------

.PHONY: shell
shell:
	$(SHELL)


.PHONY: shell/tmate
shell/tmate:
	$(eval TMATE_SOCKET := $(shell $(MKTEMP)))
	$(ECHO_INFO) "Install 'tmate' via 'brew install tmate'."
	$(ECHO_INFO) "tmate socket: $(TMATE_SOCKET)"
	$(RM) $(TMATE_SOCKET)
	$(TMATE) -S $(TMATE_SOCKET) new-session -d "$(SHELL) -l"
	$(TMATE) -S $(TMATE_SOCKET) wait tmate-ready
	$(TMATE) -S $(TMATE_SOCKET) display -p "#{tmate_ssh}"
	while test -e $(TMATE_SOCKET) && $(TMATE) -S $(TMATE_SOCKET) has-session; do sleep 1; done

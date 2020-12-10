# Adds a 'shell' target which starts a shell session from within the Makefile.
#
# Adds a 'shell/tmate' target which starts a remote shell session
# from within the Makefile using 'tmate'.
#
# ------------------------------------------------------------------------------

#	TODO Uncertain if tmate works without a pre-existing ~/.ssh/id_rsa
# SSH_KEYHEN = $(call which,SSH_KEYGEN,ssh-keygen)
# $(foreach VAR,SSH_KEYGEN,$(call make-lazy,$(VAR)))

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
#	TODO Uncertain if tmate works without a pre-existing ~/.ssh/id_rsa
#	$(MKDIR) ${HOME}/.ssh
#	[[ -e $${HOME}/.ssh/id_rsa ]] || $(SSH_KEYGEN) -q -t rsa -b 4096 -N "" -f $${HOME}/.ssh/id_rsa
	$(RM) $(TMATE_SOCKET)
	$(TMATE) -S $(TMATE_SOCKET) new-session -d "$(SHELL) -l"
	$(TMATE) -S $(TMATE_SOCKET) wait tmate-ready
	$(TMATE) -S $(TMATE_SOCKET) display -p "#{tmate_ssh}"
	while $(TEST) -e $(TMATE_SOCKET) && $(TMATE) -S $(TMATE_SOCKET) has-session; do $(SLEEP) 1; done

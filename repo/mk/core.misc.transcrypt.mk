# Adds a 'decrypt' target that will descrypt the current transcrypted repository
# by using a GPG encoded password.
#
# ------------------------------------------------------------------------------
#
# Adds a '.transcrypt/<ID>.asc' target to help share the transcrypt password
# with another GPG identity in a secure manner.
#
# ------------------------------------------------------------------------------
#
# Adds a SF_IS_TRANSCRYPTED variable to check if the repository has been decrypted.
#
# ------------------------------------------------------------------------------

SF_IS_TRANSCRYPTED = $(shell $(GIT) config --local transcrypt.version >/dev/null && echo true || echo false)

SF_VENDOR_FILES_IGNORE += \
	-e "^.transcrypt/" \
	-e "^transcrypt$$" \

KEYBASE = $(call which,KEYBASE,keybase)
$(foreach VAR,KEYBASE,$(call make-lazy,$(VAR)))

# ------------------------------------------------------------------------------

.PHONY: decrypt
decrypt: ## Decrypt this repository with transcrypt.
	$(eval KEYBASE_USER := $(shell $(KEYBASE) whoami 2>/dev/null))
	if [[ -f ".transcrypt/$(KEYBASE_USER)@keybase.io.asc" ]]; then \
		$(ECHO_INFO) "Using keybase identity $(KEYBASE_USER)@keybase.io to decrypt this repository."; \
		./transcrypt -y --import-gpg .transcrypt/$(KEYBASE_USER)@keybase.io.asc; \
	else \
		$(ECHO) "[Q   ] Which identity do you want to use to decrypt this repository?"; \
		$(LS) -1 .transcrypt | $(SED) "s/\.asc$$//g" | $(SED) "s/^/       /g"; \
		read ID && \
			./transcrypt -y --import-gpg .transcrypt/$${ID}.asc; \
	fi


.PHONY: ./transcrypt/%.asc
.transcrypt/%.asc:
	./transcrypt --export-gpg $*
	$(MKDIR) $$(dirname $@)
	$(MV) .git/crypt/$*.asc $@

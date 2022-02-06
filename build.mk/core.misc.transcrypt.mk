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
# Adds a YP_IS_TRANSCRYPTED variable to check if the repository has been decrypted.
#
# ------------------------------------------------------------------------------

YP_IS_TRANSCRYPTED = $(shell $(GIT) config --local transcrypt.version >/dev/null && $(ECHO) true || $(ECHO) false)
$(foreach VAR,YP_IS_TRANSCRYPTED,$(call make-lazy-once,$(VAR)))

YP_VENDOR_FILES_IGNORE += \
	-e "^.transcrypt/" \
	-e "^transcrypt$$" \

KEYBASE = $(call which,KEYBASE,keybase)
$(foreach VAR,KEYBASE,$(call make-lazy-once,$(VAR)))

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
		$(ECHO_INFO) "Alternatively you can enter the plain-text password."; \
		read -r ID_OR_PASS && \
			if [[ -f .transcrypt/$${ID_OR_PASS}.asc ]]; then \
				$(ECHO_INFO) "Decrypting with identity .transcrypt/$${ID_OR_PASS}.asc ."; \
				./transcrypt -y --import-gpg .transcrypt/$${ID_OR_PASS}.asc; \
			else \
				$(ECHO_INFO) "Decrypting with plain-text password."; \
				./transcrypt -y -p $${ID_OR_PASS}; \
			fi \
	fi


.PHONY: ./transcrypt/%.asc
.transcrypt/%.asc:
	./transcrypt --export-gpg $*
	$(MKDIR) $$(dirname $@)
	$(MV) .git/crypt/$*.asc $@

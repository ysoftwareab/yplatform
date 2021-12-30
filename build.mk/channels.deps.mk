# ------------------------------------------------------------------------------

YP_DEPS_TARGETS += \
	deps-channels \

# ------------------------------------------------------------------------------

.PHONY: deps-channels
deps-channels: guard-env-YP_PROMOTE_CHANNELS_GIT_URL guard-env-YP_PROMOTE_CHANNELS_DIR
	$(ECHO_DO) "Cloning $(YP_PROMOTE_CHANNELS_GIT_URL) into $(YP_PROMOTE_CHANNELS_DIR)..."
	$(GIT) check-ignore $(YP_PROMOTE_CHANNELS_DIR) || { \
		$(ECHO_ERR) "$(YP_PROMOTE_CHANNELS_DIR) should be ignored by git."; \
		$(ECHO_INFO) "Please add '/$(YP_PROMOTE_CHANNELS_DIR)' to the repository's .gitignore ."; \
		exit 1; \
	}
	$(RM) $(YP_PROMOTE_CHANNELS_DIR)
	$(GIT) clone $(YP_PROMOTE_CHANNELS_GIT_URL) $(YP_PROMOTE_CHANNELS_DIR)
	cd $(YP_PROMOTE_CHANNELS_DIR) && { \
		if $(GIT_LS) | $(GREP) -q "^yplatform$$"; then \
			$(ECHO_ERR) "You cannot have a 'yplatform' in $(YP_PROMOTE_CHANNELS_GIT_URL)."; \
			exit 1; \
		fi
		$(GIT) check-ignore yplatform || $(ECHO) "/yplatform" >> .gitignore; \
		$(LN) -s $(YP_DIR) yplatform; \
		if $(GIT_LS) | $(GREP) -q "^Makefile$$"; then \
			$(ECHO_ERR) "You cannot have a 'Makefile' in $(YP_PROMOTE_CHANNELS_GIT_URL)."; \
			exit 1; \
		fi
		$(GIT) check-ignore Makefile || $(ECHO) "/Makefile" >> .gitignore; \
		$(RM) Makefile; \
		$(ECHO) "include support-firecloud/repo/mk/core.common.mk" >> Makefile; \
		$(ECHO) "include support-firecloud/repo/mk/channels.common.mk" >> Makefile; \
		$(ECHO) "YP_PROMOTE_CHANNELS := $(YP_PROMOTE_CHANNELS)" >> Makefile; \
	}
	$(ECHO_DONE)

SF_DEPS_TARGETS := \
	$(SF_DEPS_TARGETS) \
	deps-node_modules_private \

# ------------------------------------------------------------------------------

.PHONY: deps--node_modules_private
deps-node_modules_private:
	DEPS=""; \
	for DEP_NAME in `$(CAT) package.json | $(JSON) "privateDependencies" | $(JSON) -a -k`; do \
		DEP_VSN=`$(CAT) "package.json" | $(JSON) "privateDependencies $${DEP_NAME}"`; \
		BUNDLED_DEP_VSN=`$(CAT) "node_modules_private/lib/node_modules/$${DEP_NAME}/package.json" | $(JSON) "_from"`; \
		[[ "$${DEP_VSN}" = "$${BUNDLED_DEP_VSN}" ]] || { \
			$(ECHO_ERR) "node_modules_private/lib/node_modules/$${DEP_NAME} is outdated."; \
			$(ECHO_ERR) "Found    $${DEP_VSN}."; \
			$(ECHO_ERR) "Expected $${BUNDLED_DEP_VSN}."; \
			$(ECHO_ERR) "Run <make node_modules_private> to update it."; \
			exit 1; \
		}; \
	done; \


.PHONY: node_modules_private
node_modules_private: ## Refresh node_modules_private folder.
	DEPS=""; \
	for DEP_NAME in `$(CAT) package.json | $(JSON) "privateDependencies" | $(JSON) -a -k`; do \
		DEP_VSN=`$(CAT) "package.json" | $(JSON) "privateDependencies $${DEP_NAME}"`; \
		DEPS="$${DEPS} $${DEP_NAME}@$${DEP_VSN}"; \
	done; \
	$(RM) node_modules_private/etc || true
	$(RM) node_modules_private/lib || true
	$(NPM) install --prefix node_modules_private --global $${DEPS}

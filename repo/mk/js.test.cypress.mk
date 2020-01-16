# Adds 'cypress/integration/**/*.js' targets to run jest on a specific cypress/integration/**/*.js file.
#
# ------------------------------------------------------------------------------
#
# Adds a 'test-cypress' internal target to run all SF_CYPRESS_TEST_FILES (defaults to cypress/integration/**/*.js).
# The 'test-cypress' target is automatically included in the 'test' target via SF_TEST_TARGETS.
#
# The arguments to the cypress executable can be changed via CYPRESS_ARGS.
# Cypress will by default run on the url defined in its cypress.json file.
# To run it on another url define WEB_BASE_URL before running the target.
#
# ------------------------------------------------------------------------------

WAIT_ON = $(call npm-which,WAIT_ON,wait-on)

KILL_PORT = $(call npm-which,KILL_PORT,kill-port)

CYPRESS = $(call npm-which,CYPRESS,cypress)

CYPRESS_BROWSER_TARGET ?= chrome

CYPRESS_ARGS += \
	--browser $(CYPRESS_BROWSER_TARGET) \

CYPRESS_PORT ?= 4200

CYPRESS_WEB_URL ?= http://localhost


SF_CYPRESS_TEST_FILES += \
	$(shell $(FIND_Q_NOSYM) cypress/integration -type f -name "*.js" -print) \

SF_VENDOR_FILES_IGNORE += \

SF_CLEAN_FILES += \
	cypress/videos \
	cypress/screenshots \

SF_TEST_TARGETS += \
	test-cypress

WEB_BASE_URL ?=


# ------------------------------------------------------------------------------

.PHONY: test-cypress
test-cypress:
	if [[ "$(words $(SF_CYPRESS_TEST_FILES))" != "0" ]]; then \
		echo "files exist"; \
		if [ -z "$(WEB_BASE_URL)" ]; then \
			$(MAKE) test-cypress-with-server; \
		else \
			$(MAKE) test-cypress-deployed-env; \
		fi \
	fi

.PHONY: test-cypress-deployed-env
test-cypress-deployed-env: guard-env-WEB_BASE_URL
	CYPRESS_baseUrl=$(WEB_BASE_URL) $(CYPRESS) run $(CYPRESS_ARGS)


.PHONY: test-cypress-with-server
test-cypress-with-server:
	$(MAKE) server & $(WAIT_ON) $(CYPRESS_WEB_URL):$(CYPRESS_PORT)
	$(CYPRESS) run $(CYPRESS_ARGS)
	$(KILL_PORT) $(CYPRESS_PORT)


.PHONY: test-cypress-no-server
test-cypress-no-server:
	$(CYPRESS) run $(CYPRESS_ARGS)


.PHONY: $(SF_CYPRESS_TEST_FILES)
$(SF_CYPRESS_TEST_FILES):
	$(CYPRESS) run --spec $@ $(CYPRESS_ARGS)

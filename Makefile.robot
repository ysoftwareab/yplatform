# -*- mode: Makefile;-*-

ROBOT_TARGETS := $(patsubst %.in,%.run,$(wildcard robot/*.in))

# ------------------------------------------------------------------------------

.PHONY: $(ROBOT_TARGETS)
robot/%.run: ## Trigger a specific robot execution.
$(ROBOT_TARGETS): robot/%.run: robot/%.in robot/%.out
	$(ECHO_DO) "Running $< ..."
	$(CAT) $< | bin/robot.sh --debug | $(TEE) $@
	$(ECHO_INFO) "Checking if reporting fulfills expectations..."
	$(DIFF) -u $@ $(word 2,$^)
	$(ECHO_DONE)


.PHONY: robot
robot: $(ROBOT_TARGETS) ## Trigger all robot executions.
	:


.PHONY: test/robot.sh
test/robot.sh: ## Test robot.sh script.
	vendor/bats/bin/bats test/robot.sh/*.bats

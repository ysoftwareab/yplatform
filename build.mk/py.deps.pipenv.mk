# Adds 'deps-pipenv' and 'deps-pipenv-prod' targets to install all and respectively prod-only pipenv dependencies.
# The 'deps-pipenv' target is automatically included in the 'deps' target via YP_DEPS_TARGETS.
#
# ------------------------------------------------------------------------------

PIPENV = $(call which,PIPENV,pipenv)
$(foreach VAR,PIPENV,$(call make-lazy-once,$(VAR)))

YP_CLEAN_FILES += \
	.venv \

YP_DEPS_TARGETS += \
	deps-pipenv \

export PIPENV_NO_INHERIT = 1
export PIPENV_SKIP_LOCK = 1
export PIPENV_VENV_IN_PROJECT = 1
export PIPENV_VERBOSITY = -1

# ------------------------------------------------------------------------------

.PHONY: deps-pipenv
deps-pipenv:
	$(PIPENV) install --skip-lock --dev


.PHONY: deps-pipenv-prod
deps-pipenv-prod:
	$(PIPENV) install --skip-lock

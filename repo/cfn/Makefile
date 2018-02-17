SUPPORT_FIRECLOUD_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))/..))
include $(SUPPORT_FIRECLOUD_DIR)/repo/core.inc.mk/Makefile

PATH := $(SUPPORT_FIRECLOUD_DIR):$(PATH)
export PATH

STACK_NAME ?= $(STACK_STEM)
export STACK_NAME
export STACK_STEM

CHANGE_SET_NAME = $(STACK_NAME)-$(BUILD_DATE)-$(BUILD_TIME)-$(BUILD_VCS_NUMBER)-$(MAKE_DATE)-$(MAKE_TIME)
STACK_TPL_FILE ?= $(STACK_STEM).cfn.json
STACK_TPL_FILE_BAK ?= $(STACK_TPL_FILE).bak
CHANGE_SET_FILE = $(STACK_STEM).change-set.json
CHANGE_SET_FILE_DIFF ?= $(CHANGE_SET_FILE).diff

CFN_JS_FILES := $(shell $(FIND_Q_NOSYM) . -mindepth 1 -maxdepth 1 -type f -name "*.cfn.js" -print)
CFN_JSON_FILES := $(patsubst %.cfn.js,%.cfn.json,$(CFN_JS_FILES))
INC_FILES := \
	$(shell $(FIND_Q_NOSYM) . -mindepth 2 -maxdepth 2 -type f -name "*.js" -print) \
	$(shell $(FIND_Q_NOSYM) tpl -mindepth 1 -type f -name "*.js" -print)

LINT_TARGETS := $(patsubst %.cfn.js,%.cfn.json/lint,$(CFN_JS_FILES))

STACK_STEM_HOOKS := \
	%-pre \
	%-pre-exec \
	%-post-exec \
	%-pre-rm \
	%-post-rm \

# ------------------------------------------------------------------------------

.PHONY: all
all:


.PHONY: $(CFN_JSON_FILES)
$(CFN_JSON_FILES): %.cfn.json: %.cfn.js %-setup %.cfn.json/lint $(INC_FILES) ## Generate stack template.
	@$(ECHO_DO) "Generating a valid $@..."
	$(call $(STACK_STEM)-pre)
	AWS_ACCOUNT_ID=$(AWS_ACCOUNT_ID) $(NODE_BABEL) ./$< > $@
#	FIXME validate-template only checks JSON syntax. use cloudformation-schema...
#	https://console.aws.amazon.com/support/home?region=eu-west-1#/case/?displayId=1832313261&language=en
	if $$($(AWS) s3api head-bucket --bucket $(S3_INFRA_BUCKET)); then { \
		aws-cloudformation-validate-template \
			--template-body file://$@ \
			--template-url-prefix $(S3_INFRA_BUCKET)/tmp || { \
			mv $@ $@.err; \
			$(ECHO_ERR) "Erroneous template available as $@.err ."; \
			exit 1; \
		} \
	} else { \
		$(ECHO_WARN) "$(S3_INFRA_BUCKET) does not exist."; \
		$(ECHO_WARN) "Validating the template will not take place."; \
		$(ECHO_WARN) "You will also need to manually create this stack via AWS console."; \
	} fi
	$(CAT) $@ | $(AWS_CFN2DOT) | $(DOT) -Tpng -o$@.png
	@$(ECHO_DONE)


.PHONY: %.cfn.json.bak
%.cfn.json.bak: %-setup ## Backup stack template.
	@$(ECHO_DO) "Backing up $(STACK_NAME) stack template to $(STACK_TPL_FILE_BAK)..."
	$(CFN) get-template --stack-name $(STACK_NAME) | $(JSON) "TemplateBody" > $(STACK_TPL_FILE_BAK)
	@$(ECHO_DONE)


.PHONY: %.cfn.json/lint
%.cfn.json/lint: %-setup ## Lint stack.
	$(ECHO_DO) "Linting the $(STACK_NAME) stack..."
	$(ESLINT) $(ESLINT_REPORTER) --config ./.eslintrc.yaml \
		$(STACK_STEM).js \
		$$($(FIND_Q_NOSYM) $(STACK_STEM) -type f -name "*.cfn.js" -print)
	$(call $(STACK_STEM)-lint)
	$(ECHO_DONE)


.PHONY: %.cfn.json/exec
%.cfn.json/exec: %-setup %.cfn.json ## Create/update stack.
	$(ECHO_DO) "Creating/updating $(STACK_NAME) stack..."
	$(call $(STACK_STEM)-pre-exec)
	aws-cloudformation-cu-stack \
		--wait \
		--stack-name $(STACK_NAME) \
		--change-set-name $(CHANGE_SET_NAME) \
		--change-set-file $(CHANGE_SET_FILE) \
		--template-body file://$(STACK_TPL_FILE) \
		--template-url-prefix $(S3_INFRA_BUCKET)/tmp \
		--tags Key=project,Value=$(PROJECT_DOMAIN_NAME) \
		--parameters ParameterKey=zzMtime,ParameterValue=$(MAKE_DATE).$(MAKE_TIME)
	[ $(AWS_ACCOUNT_ID) != $(PROD_AWS_ACCOUNT_ID) ] || { \
		$(AWS) cloudformation update-termination-protection --stack-name $(STACK_NAME) --enable-termination-protection; \
	}
	$(call $(STACK_STEM)-post-exec)
	$(ECHO_DONE)


.PHONY: %.cfn.json/rm
%.cfn.json/rm: %-setup ## Remove stack.
	$(ECHO_DO) "Removing $(STACK_NAME) stack..."
	$(call $(STACK_STEM)-pre-rm)
	aws-cloudformation-delete-stack \
		--wait \
		--stack-name $(STACK_NAME) \
		--empty-s3
	$(call $(STACK_STEM)-post-rm)
	$(ECHO_DONE)


.PHONY: %.change-set.json
%.change-set.json: %-setup %.cfn.json %.cfn.json.bak ## Create change-set and template diff.
	$(ECHO_DO) "Creating $(CHANGE_SET_FILE) and $(CHANGE_SET_FILE_DIFF)..."
#	for f in $(STACK_TPL_FILE_BAK) $(STACK_TPL_FILE); do \
#		$(CAT) $${f} | $(JQ) -S . > sorted.$${f}; \
#	done
	for f in $(STACK_TPL_FILE_BAK) $(STACK_TPL_FILE); do \
		$(CAT) $${f} | $(JSON) -k -a | $(SORT) > sorted.$${f}; \
	done
	$(DIFF) --unified=1000000 sorted.$(STACK_TPL_FILE_BAK) sorted.$(STACK_TPL_FILE) >$(CHANGE_SET_FILE_DIFF) || true
	$(RM) sorted.$(STACK_TPL_FILE_BAK) sorted.$(STACK_TPL_FILE)
	aws-cloudformation-cu-stack \
		--stack-name $(STACK_NAME) \
		--create-change-set \
		--change-set-name $(CHANGE_SET_NAME) \
		--change-set-file $(CHANGE_SET_FILE) \
		--template-body file://$(STACK_TPL_FILE) \
		--template-url-prefix $(S3_INFRA_BUCKET)/tmp \
		--tags Key=project,Value=$(PROJECT_DOMAIN_NAME) \
		--parameters ParameterKey=zzMtime,ParameterValue=$(MAKE_DATE).$(MAKE_TIME)
	$(ECHO) "Diff file: $(CHANGE_SET_FILE_DIFF)"
	$(ECHO_DONE)


.PHONY: %.change-set.json/exec
%.change-set.json/exec: %-setup ## Update stack with change-set.
	$(ECHO_DO) "Updating $(STACK_NAME) stack with $(CHANGE_SET_FILE)..."
	$(call $(STACK_STEM)-pre-exec)
	aws-cloudformation-cu-stack \
		--wait \
		--stack-name $(STACK_NAME) \
		--execute-change-set \
		--change-set-file $(CHANGE_SET_FILE)
	$(RM) $(CHANGE_SET_FILE)
	[ $(AWS_ACCOUNT_ID) != $(PROD_AWS_ACCOUNT_ID) ] || { \
		$(AWS) cloudformation update-termination-protection --stack-name $(STACK_NAME) --enable-termination-protection; \
	}
	$(call $(STACK_STEM)-post-exec)
	$(ECHO_DONE)


.PHONY: lint
lint: $(LINT_TARGETS)


.PHONY: check
check:
	$(MAKE) lint


.PHONY: $(STACK_STEM_HOOKS)
$(STACK_STEM_HOOKS): %-setup
	$(call $@)


include *.inc.mk

include $(SUPPORT_FIRECLOUD_DIR)/build.mk/core.inc.mk/Makefile
include $(SUPPORT_FIRECLOUD_DIR)/build.mk/core.clean.mk
include $(SUPPORT_FIRECLOUD_DIR)/build.mk/core.misc.transcrypt.mk
include $(SUPPORT_FIRECLOUD_DIR)/build.mk/core.misc.source-const-inc.mk

# need access to node-esm
PATH := $(PATH):$(SUPPORT_FIRECLOUD_DIR)/dev/bin
export PATH

# makefile-folder node_modules exebutables
PATH_NPM := $(MAKE_PATH)/node_modules/.bin
# repository node_modules executables
PATH_NPM := $(PATH_NPM):$(GIT_ROOT)/node_modules/.bin

define npm-which
$(shell \
	export PATH="$(PATH_NPM):$(PATH)"; \
	export RESULT="$$(for CMD in $(2); do $(COMMAND_Q) $${CMD} && break || continue; done)"; \
	echo "$${RESULT:-$(1)_NOT_FOUND}")
endef

AWS_ACCOUNT_ID ?= $(shell $(AWS) sts get-caller-identity --output text --query Arn 2>/dev/null | \
	$(SED) "s/^arn:aws:\(iam\|sts\):://" | \
	$(SED) "s/:.*$$//")
$(foreach VAR,AWS_ACCOUNT_ID,$(call make-lazy,$(VAR)))

AWS = $(call which,AWS,aws)
AWS_CFN_CU_STACK = $(SUPPORT_FIRECLOUD_DIR)/bin/aws-cloudformation-cu-stack
AWS_CFN_DETECT_STACK_DRIFT = $(SUPPORT_FIRECLOUD_DIR)/bin/aws-cloudformation-detect-stack-drift
AWS_CFN_D_STACK = $(SUPPORT_FIRECLOUD_DIR)/bin/aws-cloudformation-delete-stack
AWS_CFN2DOT = $(SUPPORT_FIRECLOUD_DIR)/bin/aws-cfn2dot
AWS_CFN_C_STACK_POLICY = $(SUPPORT_FIRECLOUD_DIR)/bin/aws-cloudformation-create-stack-policy
DOT = $(call which,GRAPHVIZ_DOT,dot)
$(foreach VAR,AWS AWS_CFN_CU_STACK AWS_CFN_D_STACK AWS_CFN2DOT DOT,$(call make-lazy,$(VAR)))

AWS_CFN_CU_STACK_ARGS ?=
AWS_CFN_DETECT_STACK_DRIFT_ARGS ?=

CFN_MK_FILES := $(shell $(FIND_Q_NOSYM) . -mindepth 1 -maxdepth 1 -type f -name "*.inc.mk" -print)

CHANGE_SET_NAME ?= $(STACK_NAME)-$(GIT_HASH_SHORT)-$(MAKE_DATE)-$(MAKE_TIME)
STACK_TPL_FILE ?= $(STACK_STEM).cfn.json
STACK_TPL_FILES := $(patsubst %.inc.mk,%.cfn.json,$(CFN_MK_FILES))

STACK_TPL_BAK_FILE ?= $(STACK_TPL_FILE).bak
STACK_TPL_BAK_FILES := $(patsubst %.inc.mk,%.cfn.json.bak,$(CFN_MK_FILES))

STACK_TPL_DIFF_FILE ?= $(STACK_TPL_FILE).diff
STACK_TPL_DIFF_FILES := $(patsubst %.inc.mk,%.cfn.json.diff,$(CFN_MK_FILES))

STACK_DRIFT_FILE ?= $(STACK_STEM).drift.json
STACK_DRIFT_FILES := $(patsubst %.inc.mk,%.drift.json,$(CFN_MK_FILES))

STACK_DRIFT_BAK_FILE ?= $(STACK_STEM).drift.json.bak
STACK_DRIFT_BAK_FILES := $(patsubst %.inc.mk,%.drift.json.bak,$(CFN_MK_FILES))

STACK_POLICY_FILE ?= $(STACK_STEM).cfn.policy.json
STACK_POLICY_FILES := $(patsubst %.inc.mk,%.cfn.policy.json,$(CFN_MK_FILES))

STACK_POLICY_BAK_FILE ?= $(STACK_POLICY_FILE).bak
STACK_POLICY_BAK_FILES := $(patsubst %.inc.mk,%.cfn.policy.json.bak,$(CFN_MK_FILES))

CHANGE_SET_FILE ?= $(STACK_STEM).change-set.json
CHANGE_SET_FILES := $(patsubst %.inc.mk,%.change-set.json,$(CFN_MK_FILES))

SF_CLEAN_FILES := \
	$(SF_CLEAN_FILES) \
	$(STACK_TPL_FILES) \
	$(STACK_TPL_BAK_FILES) \
	$(STACK_TPL_DIFF_FILES) \
	$(STACK_DRIFT_FILES) \
	$(STACK_POLICY_FILES) \
	$(STACK_POLICY_BAK_FILES) \
	$(CHANGE_SET_FILES) \

CFN_INDEX_FILE := index.js

STACK_STEM_HOOKS := \
	%-pre \
	%-pre-exec \
	%-post-exec \
	%-pre-rm \
	%-post-rm \

# ------------------------------------------------------------------------------

.PHONY: all
all: $(STACK_TPL_FILES)


.PHONY: $(STACK_TPL_FILES)
$(STACK_TPL_FILES): %.cfn.json: %-setup ## Generate stack template.
	$(ECHO_DO) "Generating a valid $@..."
	$(call $(STACK_STEM)-pre)
	./$*/$(CFN_INDEX_FILE) > $@
#	FIXME validate-template only checks JSON syntax. use cloudformation-schema...
#	https://console.aws.amazon.com/support/home?region=eu-west-1#/case/?displayId=1832313261&language=en
	if $$($(AWS) s3 ls --page-size 1 $(TMP_S3_URL) >/dev/null); then { \
		aws-cloudformation-validate-template \
			--template-body file://$@ \
			--template-url-prefix $(TMP_S3_URL) || { \
			mv $@ $@.err; \
			$(ECHO_ERR) "Erroneous template available as $@.err ."; \
			exit 1; \
		} \
	} else { \
		$(ECHO_WARN) "Cannot access $(TMP_S3_URL)."; \
		$(ECHO_WARN) "Validating the template will not take place."; \
		$(ECHO_WARN) "You will also need to manually create this stack via AWS console."; \
	} fi
#	[[ $(DOT) = "GRAPHVIZ_DOT_NOT_FOUND" ]] || \
#		$(CAT) $@ | $(AWS_CFN2DOT) | $(DOT) -Tpng -o$@.png
	$(call $(STACK_STEM)-post)
	$(ECHO_DONE)


.PHONY: %.cfn.json.bak
%.cfn.json.bak: %-setup ## Backup stack template.
	$(ECHO_DO) "Backing up $(STACK_NAME) stack template to $(STACK_TPL_BAK_FILE)..."
	$(AWS) cloudformation get-template --stack-name $(STACK_NAME) | $(JQ) -r ".TemplateBody" > $(STACK_TPL_BAK_FILE)
	$(ECHO_DONE)


.PHONY: %.cfn.json/exec
%.cfn.json/exec: %-setup %.cfn.json %.cfn.policy.json %.cfn.policy.json.bak ## Create/update stack.
	$(ECHO_DO) "Creating/updating $(STACK_NAME) stack..."
	$(call $(STACK_STEM)-pre-exec)
	$(AWS_CFN_CU_STACK) \
		--wait \
		--stack-name $(STACK_NAME) \
		--change-set-name $(CHANGE_SET_NAME) \
		--change-set-file $(CHANGE_SET_FILE) \
		--template-body file://$(STACK_TPL_FILE) \
		--template-url-prefix $(TMP_S3_URL) \
		$(AWS_CFN_CU_STACK_ARGS)
	$(ECHO_DO) "Updating $(STACK_NAME) stack policy..."
	$(AWS) cloudformation set-stack-policy \
		--stack-name $(STACK_NAME) \
		--stack-policy-body file://$(STACK_POLICY_FILE)
	$(ECHO_DONE)
	$(MAKE) $(STACK_DRIFT_FILE)
	$(call $(STACK_STEM)-post-exec)
	$(ECHO_DONE)


.PHONY: %.cfn.json/rm
%.cfn.json/rm: %-setup ## Remove stack.
	$(ECHO_DO) "Removing $(STACK_NAME) stack policy (allowing all changes)..."
	$(AWS) cloudformation set-stack-policy \
		--stack-name $(STACK_NAME) \
		--stack-policy-body '{"Statement":[{"Effect":"Allow","Action":"Update:*","Principal":"*","Resource":"*"}]}'
	$(ECHO_DONE)
	$(ECHO_DO) "Removing $(STACK_NAME) stack..."
	$(call $(STACK_STEM)-pre-rm)
	$(AWS_CFN_D_STACK) \
		--wait \
		--stack-name $(STACK_NAME) \
		--empty-s3
	$(call $(STACK_STEM)-post-rm)
	$(ECHO_DONE)


.PHONY: %.cfn.json.diff
%.cfn.json.diff: %-setup %.cfn.json %.cfn.json.bak
	$(ECHO_DO) "Creating $(STACK_TPL_DIFF_FILE)..."
	for f in $(STACK_TPL_BAK_FILE) $(STACK_TPL_FILE); do \
		$(CAT) $${f} | $(JQ) -S . > sorted.$${f}; \
	done
	$(DIFF) --unified=1000000 sorted.$(STACK_TPL_BAK_FILE) sorted.$(STACK_TPL_FILE) >$(STACK_TPL_DIFF_FILE) || true
	$(RM) sorted.$(STACK_TPL_BAK_FILE) sorted.$(STACK_TPL_FILE)
	$(ECHO_DONE)


.PHONY: %.cfn.policy.json
%.cfn.policy.json: %-setup %.cfn.json ## Generate stack policy.
	$(ECHO_DO) "Generating stack policy for $(STACK_NAME)..."
	$(AWS_CFN_C_STACK_POLICY) $(STACK_TPL_FILE) > $(STACK_POLICY_FILE)
	$(ECHO_DONE)


.PHONY: %.cfn.policy.json.bak
%.cfn.policy.json.bak: %-setup ## Back up stack policy.
	$(ECHO_DO) "Backing up current stack policy for $(STACK_NAME)..."
	$(AWS) cloudformation get-stack-policy --stack-name $(STACK_NAME) | \
		$(JQ) -r ".StackPolicyBody" > $(STACK_POLICY_BAK_FILE) || true
	$(ECHO_DONE)


.PHONY: %.drift.json
%.drift.json: %-setup
	$(ECHO_DO) "Collecting drifts for $(STACK_NAME)..."
	$(AWS_CFN_DETECT_STACK_DRIFT) \
		--stack-name $(STACK_NAME) \
		--drift-file $(STACK_DRIFT_FILE) \
		$(AWS_CFN_DETECT_STACK_DRIFT_ARGS) || true
	$(ECHO_DONE)


.PHONY: %.drift.json.bak
%.drift.json.bak: %-setup
	$(ECHO_DO) "Backing up current drifts for $(STACK_NAME)..."
	$(AWS_CFN_DETECT_STACK_DRIFT) \
		--stack-name $(STACK_NAME) \
		--drift-file $(STACK_DRIFT_BAK_FILE) \
		$(AWS_CFN_DETECT_STACK_DRIFT_ARGS) || true
	$(ECHO_DONE)

CHANGE_SET_FILE_DEPS := \
	%.cfn.json.diff \
	%.cfn.policy.json \
	%.cfn.policy.json.bak \
	%.drift.json.bak
.PHONY: %.change-set.json
%.change-set.json: $(CHANGE_SET_FILE_DEPS) ## Create change-set and template diff.
	$(ECHO_DO) "Creating $(CHANGE_SET_FILE)..."
	$(AWS_CFN_CU_STACK) \
		--stack-name $(STACK_NAME) \
		--create-change-set \
		--change-set-name $(CHANGE_SET_NAME) \
		--change-set-file $(CHANGE_SET_FILE) \
		--template-body file://$(STACK_TPL_FILE) \
		--template-url-prefix $(TMP_S3_URL) \
		$(AWS_CFN_CU_STACK_ARGS)
	$(ECHO) "Diff file: $(STACK_TPL_DIFF_FILE)"
	$(ECHO_DONE)


.PHONY: %.change-set.json/exec
%.change-set.json/exec: %-setup ## Update stack with change-set.
	$(ECHO_DO) "Updating $(STACK_NAME) stack with $(CHANGE_SET_FILE)..."
	$(call $(STACK_STEM)-pre-exec)
	$(AWS_CFN_CU_STACK) \
		--wait \
		--stack-name $(STACK_NAME) \
		--execute-change-set \
		--change-set-file $(CHANGE_SET_FILE)
	$(RM) $(CHANGE_SET_FILE)
	$(ECHO_DO) "Updating $(STACK_NAME) stack policy..."
	$(AWS) cloudformation set-stack-policy \
		--stack-name $(STACK_NAME) \
		--stack-policy-body file://$(STACK_POLICY_FILE)
	$(ECHO_DONE)
	$(MAKE) $(STACK_DRIFT_FILE)
	$(call $(STACK_STEM)-post-exec)
	$(ECHO_DONE)


.PHONY: $(STACK_STEM_HOOKS)
$(STACK_STEM_HOOKS): %-setup
	$(call $@)

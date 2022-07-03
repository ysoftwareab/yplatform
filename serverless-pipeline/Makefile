AWS := aws --profile ysoftwareab_iam_andrei

INFRA_BUCKET := cf-templates-4aj0d980sudw-eu-north-1
STACK_NAME := serverless-pipeline
TPL_TMP := $(shell mktemp)

all:
	$(AWS) cloudformation package --template-file <(./index.js) --s3-bucket $(INFRA_BUCKET) --output-template-file $(TPL_TMP)
	$(AWS) s3 cp $(CFN_TMP) s3://$(INFRA_BUCKET)/$(STACK_NAME)/$(notdir $(TPL_TMP))
	$(AWS) cloudformation update-stack --template-body $$(cat $(CFN_TMP)) --stack-name $(STACK_NAME) --disable-rollback --capabilities CAPABILITY_IAM

SHELL := bash

AWS := aws --profile ysoftwareab_iam_andrei

INFRA_BUCKET := cf-templates-4aj0d980sudw-eu-north-1
STACK_NAME := serverless-pipeline
TPL_TMP := $(shell mktemp)

all:
	./index.js > $(TPL_TMP)
	$(AWS) cloudformation package --template-file $(TPL_TMP) --s3-bucket $(INFRA_BUCKET) --output-template-file $(TPL_TMP).packaged
	$(AWS) cloudformation deploy --template-file $(TPL_TMP).packaged --stack-name $(STACK_NAME) --capabilities CAPABILITY_IAM

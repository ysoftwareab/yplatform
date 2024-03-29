export YP_DIR := $(abspath $(shell dirname $(lastword $(MAKEFILE_LIST)))/<YP_DIR_REL>)
include $(YP_DIR)/aws-cfn.mk/inc.mk

STACK_DIR ?= $(MAKE_PATH)/$(STACK_STEM)
STACK_NAME ?= $(patsubst env-%,$(ENV_NAME)-%,$(STACK_STEM))

# An S3 url to interact with temporary artifats
# e.g. s3://example/path
# TMP_S3_URL :=

# Optional

# `aws cloudformation create-stack/update-stack` arguments
# e.g.
#    --tags \
#    Key=project,Value=someproject \
#    Key=stack,Value=$(STACK_NAME) \
#    --parameters \
#    ParameterKey=somekey,ParameterValue=somevalue \
#
# AWS_CFN_CU_STACK_ARGS :=

include *.inc.mk

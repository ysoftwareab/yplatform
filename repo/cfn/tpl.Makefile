export SUPPORT_FIRECLOUD_DIR := $(abspath $(shell dirname $(lastword $(MAKEFILE_LIST)))/<SUPPORT_FIRECLOUD_DIR_REL>)
include $(SUPPORT_FIRECLOUD_DIR)/repo/cfn/Makefile

# An S3 url to interact with temporary artifats
# e.g. s3://example/path
# TMP_S3_URL :=

# Optional

# `aws cloudformation create-stack/update-stack` arguments
# e.g. --tags Key=project,Value=someproject --parameters ParameterKey=somekey,ParameterValue=somevalue
# AWS_CFN_CU_STACK_ARGS :=

# `eslint` arguments
# e.g. --reporter html
# ESLINT_ARGS :=

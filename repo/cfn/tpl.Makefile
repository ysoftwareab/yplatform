export SUPPORT_FIRECLOUD_DIR := $(abspath $(shell dirname $(lastword $(MAKEFILE_LIST)))/<SUPPORT_FIRECLOUD_DIR_REL>)
include $(SUPPORT_FIRECLOUD_DIR)/repo/cfn/Makefile

# An S3 url to interact with temporary artifats
# e.g. s3://example/path
# TMP_S3_URL :=

# Optional
# AWS_CFN_CU_STACK_ARGS := \
#   --tags Key=project,Value=$(PROJECT_DOMAIN_NAME) \
#		--parameters ParameterKey=zzMtime,ParameterValue=$(MAKE_DATE).$(MAKE_TIME)
# ESLINT_ARGS := \
# 	--reporter html

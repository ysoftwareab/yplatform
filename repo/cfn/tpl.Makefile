export SUPPORT_FIRECLOUD_DIR := $(abspath $(shell dirname $(lastword $(MAKEFILE_LIST)))/<SUPPORT_FIRECLOUD_DIR_REL>)
include $(SUPPORT_FIRECLOUD_DIR)/repo/cfn/Makefile

# S3_INFRA_BUCKET :=

# Optional
# AWS_CFN_CU_STACK_ARGS := \
#   --tags Key=project,Value=$(PROJECT_DOMAIN_NAME) \
#		--parameters ParameterKey=zzMtime,ParameterValue=$(MAKE_DATE).$(MAKE_TIME)
# ESLINT_ARGS := \
# 	--reporter html

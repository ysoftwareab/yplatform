CORE_INC_MK_PATH := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

include $(CORE_INC_MK_PATH)/core.inc.mk
include $(CORE_INC_MK_PATH)/os.inc.mk
include $(CORE_INC_MK_PATH)/git.inc.mk
include $(CORE_INC_MK_PATH)/exe.inc.mk

include $(CORE_INC_MK_PATH)/target.env.inc.mk
include $(CORE_INC_MK_PATH)/target.help.inc.mk
include $(CORE_INC_MK_PATH)/target.noop.inc.mk
include $(CORE_INC_MK_PATH)/target.printvar.inc.mk

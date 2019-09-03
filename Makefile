ifdef INSTALL_CORE_INC_MK
else

CORE_INC_MK_DIR ?= $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

include $(CORE_INC_MK_DIR)/core.inc.mk
include $(CORE_INC_MK_DIR)/os.inc.mk
include $(CORE_INC_MK_DIR)/exe.inc.mk
include $(CORE_INC_MK_DIR)/git.inc.mk

include $(CORE_INC_MK_DIR)/target.env.inc.mk
include $(CORE_INC_MK_DIR)/target.help.inc.mk
include $(CORE_INC_MK_DIR)/target.noop.inc.mk
include $(CORE_INC_MK_DIR)/target.printvar.inc.mk

INSTALL_CORE_INC_MK := 1
endif

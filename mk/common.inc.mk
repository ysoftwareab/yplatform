ifdef INSTALL_CORE_INC_MK
else

ifndef CORE_INC_MK_DIR
CORE_INC_MK_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))
endif

# defined here for consistency, later defined properly in exe.gnu.inc.mk
DATE := date
ECHO := echo
GREP := grep
PYTHON := python

include $(CORE_INC_MK_DIR)/chars.inc.mk
include $(CORE_INC_MK_DIR)/core.inc.mk

include $(CORE_INC_MK_DIR)/exe.inc.mk
include $(CORE_INC_MK_DIR)/os.inc.mk
include $(CORE_INC_MK_DIR)/git.inc.mk

include $(CORE_INC_MK_DIR)/target.env.inc.mk
include $(CORE_INC_MK_DIR)/target.help.inc.mk
include $(CORE_INC_MK_DIR)/target.noop.inc.mk
include $(CORE_INC_MK_DIR)/target.printvar.inc.mk
include $(CORE_INC_MK_DIR)/target.sentinel.inc.mk
include $(CORE_INC_MK_DIR)/target.verbose.inc.mk
include $(CORE_INC_MK_DIR)/target.lazy.inc.mk

MAKEFILE_LAZY ?= true
ifeq (true,$(MAKEFILE_LAZY))
MAKECMDGOALS ?=
ifeq ($(MAKECMDGOALS),$(filter-out %Makefile.lazy,$(MAKECMDGOALS)))
ifeq (,$(wildcard Makefile.lazy))
$(info [DO  ] Generating Makefile.lazy...)
$(info $(shell $(MAKE) Makefile.lazy))
$(info [DONE])
$(info )
endif
include Makefile.lazy
endif
endif

INSTALL_CORE_INC_MK := 1
endif

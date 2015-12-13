COMPONENT=LocalizationAppC
#CFLAGS += /home/vedangi/tinyos-main/tos/lib/printf/
CFLAGS += -I$(TINYOS_OS_DIR)/lib/printf
PFLAGS += -DNEW_PRINTF_SEMANTICS
TINYOS_ROOT_DIR?=../..
include $(TINYOS_ROOT_DIR)/Makefile.include

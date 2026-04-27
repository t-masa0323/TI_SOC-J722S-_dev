ifeq ($(TARGET_OS), $(filter $(TARGET_OS), LINUX QNX))

include $(PRELUDE)

TARGET      := app_utils_init
TARGETTYPE  := library

CSOURCES    := app_init.c

CFLAGS += -finstrument-functions
CFLAGS += -g3
CFLAGS += -gdwarf-4
CFLAGS += -O0
CFLAGS += -fno-omit-frame-pointer

LDFLAGS += -rdynamic
LDFLAGS += -Wl,-export-dynamic

ifeq ($(TARGET_CPU), x86_64)
CFLAGS      := -DTARGET_X86_64
endif

include $(FINALE)

endif


ifeq ($(BUILD_CPU_MPU1),yes)
ifeq ($(TARGET_CPU),A53)
ifeq ($(TARGET_OS),LINUX)

include $(PRELUDE)

TARGET      := app_rtos_linux_mpu1_common
TARGETTYPE  := library
CSOURCES    := $(call all-c-files)

CFLAGS += -finstrument-functions
CFLAGS += -g3
CFLAGS += -gdwarf-4
CFLAGS += -O0
CFLAGS += -fno-omit-frame-pointer

LDFLAGS += -rdynamic
LDFLAGS += -Wl,-export-dynamic

IDIRS+=$(VISION_APPS_PATH)/platform/$(SOC)/linux
IDIRS+=$(VISION_APPS_PATH)/platform/$(SOC)/rtos
IDIRS+=$(VISION_APPS_PATH)/platform/$(SOC)/rtos/common

include $(FINALE)

endif
endif
endif
                                                   

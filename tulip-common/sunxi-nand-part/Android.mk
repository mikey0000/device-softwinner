##
## Sources are taken from https://github.com/linux-sunxi/sunxi-tools
##

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := nand-part-main.c nand-part.c
LOCAL_C_INCLUDES := $(LOCAL_PATH)/include/
LOCAL_CFLAGS := -DA64
LOCAL_MODULE = sunxi-nand-part
include $(BUILD_HOST_EXECUTABLE)

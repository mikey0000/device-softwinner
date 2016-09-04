LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := SideloadLauncher
LOCAL_MODULE_TAGS := optional
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_CLASS := APPS
LOCAL_SRC_FILES := SideloadLauncher.apk
include $(BUILD_PREBUILT)

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := ChromeBrowser
LOCAL_MODULE_TAGS := optional
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_CLASS := APPS
LOCAL_MODULE_PATH := preinstall
LOCAL_SRC_FILES := Chrome.apk
include $(BUILD_PREBUILT)

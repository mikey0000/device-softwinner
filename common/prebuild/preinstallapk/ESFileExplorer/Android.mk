###############################################################################
# ESFileExplorer
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := ESFileExplorer
LOCAL_MODULE_TAGS := optional
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_CLASS := APPS
LOCAL_SRC_FILES := ES_File_Explorer_3.2.5.1.apk
include $(BUILD_PREBUILT)

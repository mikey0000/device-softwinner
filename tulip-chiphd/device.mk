$(call inherit-product, device/softwinner/tulip-common/tulip_64_bit.mk)
$(call inherit-product, device/softwinner/tulip-common/tulip-common.mk)
$(call inherit-product, frameworks/native/build/tablet-7in-xhdpi-2048-dalvik-heap.mk)
$(call inherit-product, hardware/realtek/bluetooth/firmware/rtlbtfw_cfg.mk)

KERNEL_SRC_DIR ?= linux/kernel-tulip
KERNEL_CFG_NAME ?= sun50iw1p1smp_android
TARGET_KERNEL_ARCH ?= arm64

# Check for availability of kernel source
ifneq ($(wildcard $(KERNEL_SRC_DIR)/Makefile),)
  # Give precedence to TARGET_PREBUILT_KERNEL
  ifeq ($(TARGET_PREBUILT_KERNEL),)
    TARGET_KERNEL_BUILT_FROM_SOURCE := true
  endif
endif

ifneq ($(TARGET_KERNEL_BUILT_FROM_SOURCE), true)
# Use prebuilt kernel
ifeq ($(TARGET_PREBUILT_KERNEL),)
LOCAL_KERNEL := device/softwinner/tulip-chiphd/kernel
else
LOCAL_KERNEL := $(TARGET_PREBUILT_KERNEL)
PRODUCT_COPY_FILES += $(TARGET_PREBUILT_KERNEL_MODULES)
endif

PRODUCT_COPY_FILES += \
    $(LOCAL_KERNEL):kernel

endif # TARGET_KERNEL_BUILT_FROM_SOURCE

PRODUCT_PACKAGES += \
    hdmi_cec.tulip \
    power.tulip

DEVICE_PACKAGE_OVERLAYS := \
    device/softwinner/tulip-chiphd/overlay \
    $(DEVICE_PACKAGE_OVERLAYS)

PRODUCT_COPY_FILES += \
    device/softwinner/tulip-chiphd/fstab.sun50iw1p1:root/fstab.sun50iw1p1 \
    device/softwinner/tulip-chiphd/init.sun50iw1p1.rc:root/init.sun50iw1p1.rc \
    device/softwinner/tulip-chiphd/init.recovery.sun50iw1p1.rc:root/init.recovery.sun50iw1p1.rc \
    device/softwinner/tulip-chiphd/ueventd.sun50iw1p1.rc:root/ueventd.sun50iw1p1.rc \
    device/softwinner/tulip-chiphd/recovery.fstab:recovery.fstab

PRODUCT_COPY_FILES += \
    device/softwinner/tulip-chiphd/twrp.fstab:recovery/root/etc/twrp.fstab

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.camera.xml:system/etc/permissions/android.hardware.camera.xml \
    frameworks/native/data/etc/android.hardware.camera.front.xml:system/etc/permissions/android.hardware.camera.front.xml \
    frameworks/native/data/etc/android.hardware.bluetooth.xml:system/etc/permissions/android.hardware.bluetooth.xml \
    frameworks/native/data/etc/android.hardware.bluetooth_le.xml:system/etc/permissions/android.hardware.bluetooth_le.xml \
    frameworks/native/data/etc/android.hardware.ethernet.xml:system/etc/permissions/android.hardware.ethernet.xml \
    frameworks/native/data/etc/android.hardware.hdmi.cec.xml:system/etc/permissions/android.hardware.hdmi.cec.xml \

PRODUCT_COPY_FILES += \
    device/softwinner/tulip-chiphd/configs/camera.cfg:system/etc/camera.cfg \
    device/softwinner/tulip-chiphd/configs/gsensor.cfg:system/usr/gsensor.cfg \
    device/softwinner/tulip-chiphd/configs/media_profiles.xml:system/etc/media_profiles.xml \
    device/softwinner/tulip-chiphd/configs/sunxi-keyboard.kl:system/usr/keylayout/sunxi-keyboard.kl \
    device/softwinner/tulip-chiphd/configs/sunxi_ir_recv.kl:system/usr/keylayout/sunxi_ir_recv.kl \
    device/softwinner/tulip-chiphd/configs/tp.idc:system/usr/idc/tp.idc

PRODUCT_COPY_FILES += \
    device/softwinner/tulip-chiphd/configs/camera.cfg:system/etc/camera.cfg \
    device/softwinner/tulip-chiphd/configs/gsensor.cfg:system/usr/gsensor.cfg \
    device/softwinner/tulip-chiphd/configs/media_profiles.xml:system/etc/media_profiles.xml \
    device/softwinner/tulip-chiphd/configs/sunxi-keyboard.kl:system/usr/keylayout/sunxi-keyboard.kl \
    device/softwinner/tulip-chiphd/configs/sunxi_ir_recv.kl:system/usr/keylayout/sunxi_ir_recv.kl \
    device/softwinner/tulip-chiphd/configs/tp.idc:system/usr/idc/tp.idc

#PRODUCT_COPY_FILES += \
    device/softwinner/tulip-chiphd/hawkview/sensor_list_cfg.ini:system/etc/hawkview/sensor_list_cfg.ini

# bootanimation
PRODUCT_COPY_FILES += \
    device/softwinner/tulip-chiphd/media/bootanimation.zip:system/media/bootanimation.zip

PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    ro.boot.console=console

PRODUCT_PROPERTY_OVERRIDES += \
    ro.product.8723b_bt.used=true

PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.usb.config=mtp,adb \
    ro.adb.secure=0 \
    rw.logger=0

PRODUCT_PROPERTY_OVERRIDES += \
    ro.product.firmware=v1.2.5

PRODUCT_PROPERTY_OVERRIDES += \
    ro.zygote.disable_gl_preload=false

PRODUCT_PROPERTY_OVERRIDES += \
    ro.spk_dul.used=false \

PRODUCT_PROPERTY_OVERRIDES += \
    service.adb.tcp.port=5555 \
    persist.ota.server.ip=ota.pine64.org

PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.timezone=America/Los_Angeles \
    persist.sys.country=US \
    persist.sys.language=en

#define virtual mouse key
PRODUCT_PROPERTY_OVERRIDES += \
    ro.softmouse.left.code=16 \
    ro.softmouse.right.code=17 \
    ro.softmouse.top.code=11 \
    ro.softmouse.bottom.code=14 \
    ro.softmouse.leftbtn.code=13 \
    ro.softmouse.midbtn.code=-1 \
    ro.softmouse.rightbtn.code=-1

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.app_widgets.xml:system/etc/permissions/android.software.app_widgets.xml

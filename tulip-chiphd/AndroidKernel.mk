ifeq ($(TARGET_KERNEL_BUILT_FROM_SOURCE),true)

# Force using bash as a shell, otherwise, on Ubuntu, dash will break some
# dependency due to its bad handling of echo \1
MAKE += SHELL=/bin/bash

ifeq ($(KERNEL_CFG_NAME),)
$(error cannot build kernel, config not specified)
endif

KERNEL_MODULES_TO_ROOT := nand.ko sunxi_tr.ko disp.ko hdmi.ko sw-device.ko gslX680new.ko

KERNEL_TOOLCHAIN_ARCH := $(TARGET_KERNEL_ARCH)
KERNEL_EXTRA_FLAGS := ANDROID_TOOLCHAIN_FLAGS="-mno-android -Werror"
KERNEL_CROSS_COMP := $(notdir $(TARGET_TOOLS_PREFIX))

KERNEL_CCACHE :=$(firstword $(TARGET_CC))
KERNEL_PATH := $(ANDROID_BUILD_TOP)/vendor/pine64/support
ifeq ($(notdir $(KERNEL_CCACHE)),ccache)
KERNEL_CROSS_COMP := "ccache $(KERNEL_CROSS_COMP)"
KERNEL_PATH := $(KERNEL_PATH):$(ANDROID_BUILD_TOP)/$(dir $(KERNEL_CCACHE))
endif

#remove time_macros from ccache options, it breaks signing process
KERNEL_CCSLOP := $(filter-out time_macros,$(subst $(comma), ,$(CCACHE_SLOPPINESS)))
KERNEL_CCSLOP := $(subst $(space),$(comma),$(KERNEL_CCSLOP))

KERNEL_OUT_DIR := $(ANDROID_BUILD_TOP)/$(PRODUCT_OUT)/linux/kernel
KERNEL_MODINSTALL := modules_install
KERNEL_OUT_MODINSTALL := $(KERNEL_OUT_DIR)/$(KERNEL_MODINSTALL)
KERNEL_MODULES_ROOT := $(PRODUCT_OUT)/root
KERNEL_MODULES_VENDOR := $(PRODUCT_OUT)/system/vendor/modules
KERNEL_CONFIG := $(KERNEL_OUT_DIR)/.config
KERNEL_BLD_FLAGS := \
    ARCH=$(TARGET_KERNEL_ARCH) \
    INSTALL_MOD_PATH=$(KERNEL_MODINSTALL) \
    $(KERNEL_EXTRA_FLAGS)

KERNEL_BLD_FLAGS :=$(KERNEL_BLD_FLAGS) \
     O=$(KERNEL_OUT_DIR) \

KERNEL_BLD_ENV := CROSS_COMPILE=$(KERNEL_CROSS_COMP) \
    PATH=$(KERNEL_PATH):$(PATH) \
    CCACHE_SLOPPINESS=$(KERNEL_CCSLOP)
KERNEL_FAKE_DEPMOD := $(KERNEL_OUT_DIR)/fakedepmod/lib/modules

KERNEL_DEFCONFIG ?= $(KERNEL_SRC_DIR)/arch/$(TARGET_KERNEL_ARCH)/configs/$(KERNEL_CFG_NAME)_defconfig
KERNEL_VERSION_FILE := $(KERNEL_OUT_DIR)/include/config/kernel.release
KERNEL_BZIMAGE := $(PRODUCT_OUT)/kernel

$(KERNEL_CONFIG): $(KERNEL_DEFCONFIG)
	$(hide) echo Regenerating kernel config $(KERNEL_OUT_DIR)
	$(hide) mkdir -p $(KERNEL_OUT_DIR)
	$(hide) $(KERNEL_BLD_ENV) $(MAKE) -C $(KERNEL_SRC_DIR) $(KERNEL_BLD_FLAGS) $(notdir $(KERNEL_DEFCONFIG))

ifeq (,$(filter build_kernel-nodeps,$(MAKECMDGOALS)))
$(KERNEL_BZIMAGE): $(MINIGZIP)
endif

$(KERNEL_BZIMAGE): $(KERNEL_CONFIG)
	$(hide) $(KERNEL_BLD_ENV) $(MAKE) -C $(KERNEL_SRC_DIR) $(KERNEL_BLD_FLAGS)
	$(hide) $(KERNEL_BLD_ENV) $(MAKE) -C $(KERNEL_SRC_DIR) M=$(KERNEL_SRC_DIR)/modules/aw_schw $(KERNEL_BLD_FLAGS)
	$(hide) $(KERNEL_BLD_ENV) $(MAKE) -C $(KERNEL_SRC_DIR) M=$(KERNEL_SRC_DIR)/modules/nand/sun50iw1p1 $(KERNEL_BLD_FLAGS)
	$(hide) $(KERNEL_BLD_ENV) $(MAKE) -C $(KERNEL_SRC_DIR) M=$(KERNEL_SRC_DIR)/modules/gpu/mali400/kernel_mode/driver/src/devicedrv/mali $(KERNEL_BLD_FLAGS) $(MALI_BUILD_FLAGS)
	$(hide) cp -f $(KERNEL_OUT_DIR)/arch/arm64/boot/Image $@

$(KERNEL_OUT_MODINSTALL): $(KERNEL_BZIMAGE)
	$(hide) mkdir -p $(KERNEL_OUT_MODINSTALL)
	$(hide) $(KERNEL_BLD_ENV) $(MAKE) -C $(KERNEL_SRC_DIR) $(KERNEL_BLD_FLAGS) modules
	$(hide) $(KERNEL_BLD_ENV) $(MAKE) -C $(KERNEL_SRC_DIR) M=$(KERNEL_SRC_DIR)/modules/aw_schw $(KERNEL_BLD_FLAGS) modules
	$(hide) $(KERNEL_BLD_ENV) $(MAKE) -C $(KERNEL_SRC_DIR) M=$(KERNEL_SRC_DIR)/modules/nand/sun50iw1p1 $(KERNEL_BLD_FLAGS) modules
	$(hide) $(KERNEL_BLD_ENV) $(MAKE) -C $(KERNEL_SRC_DIR) M=$(KERNEL_SRC_DIR)/modules/gpu/mali400/kernel_mode/driver/src/devicedrv/mali $(KERNEL_BLD_FLAGS) $(MALI_BUILD_FLAGS) modules
	$(hide) $(KERNEL_BLD_ENV) $(MAKE) -C $(KERNEL_SRC_DIR) $(KERNEL_BLD_FLAGS) modules_install
	$(hide) $(KERNEL_BLD_ENV) $(MAKE) -C $(KERNEL_SRC_DIR) M=$(KERNEL_SRC_DIR)/modules/aw_schw $(KERNEL_BLD_FLAGS) modules_install
	$(hide) $(KERNEL_BLD_ENV) $(MAKE) -C $(KERNEL_SRC_DIR) M=$(KERNEL_SRC_DIR)/modules/nand/sun50iw1p1 $(KERNEL_BLD_FLAGS) modules_install
	$(hide) $(KERNEL_BLD_ENV) $(MAKE) -C $(KERNEL_SRC_DIR) M=$(KERNEL_SRC_DIR)/modules/gpu/mali400/kernel_mode/driver/src/devicedrv/mali $(KERNEL_BLD_FLAGS) $(MALI_BUILD_FLAGS) modules_install

mrproper_kernel:
	$(hide) $(KERNEL_BLD_ENV) $(MAKE) -C $(KERNEL_SRC_DIR) M=$(KERNEL_SRC_DIR)/modules/aw_schw $(KERNEL_BLD_FLAGS) clean
	$(hide) $(KERNEL_BLD_ENV) $(MAKE) -C $(KERNEL_SRC_DIR) M=$(KERNEL_SRC_DIR)/modules/nand/sun50iw1p1 $(KERNEL_BLD_FLAGS) clean
	$(hide) $(KERNEL_BLD_ENV) $(MAKE) -C $(KERNEL_SRC_DIR) M=$(KERNEL_SRC_DIR)/modules/gpu/mali400/kernel_mode/driver/src/devicedrv/mali $(KERNEL_BLD_FLAGS) $(MALI_BUILD_FLAGS) clean
	$(hide) $(KERNEL_BLD_ENV) $(MAKE) -C $(KERNEL_SRC_DIR) $(KERNEL_BLD_FLAGS) mrproper

clean_kernel:
	$(hide) $(KERNEL_BLD_ENV) $(MAKE) -C $(KERNEL_SRC_DIR) M=$(KERNEL_SRC_DIR)/modules/aw_schw $(KERNEL_BLD_FLAGS) clean
	$(hide) $(KERNEL_BLD_ENV) $(MAKE) -C $(KERNEL_SRC_DIR) M=$(KERNEL_SRC_DIR)/modules/nand/sun50iw1p1 $(KERNEL_BLD_FLAGS) clean
	$(hide) $(KERNEL_BLD_ENV) $(MAKE) -C $(KERNEL_SRC_DIR) M=$(KERNEL_SRC_DIR)/modules/gpu/mali400/kernel_mode/driver/src/devicedrv/mali $(KERNEL_BLD_FLAGS) $(MALI_BUILD_FLAGS) clean
	$(hide) $(KERNEL_BLD_ENV) $(MAKE) -C $(KERNEL_SRC_DIR) $(KERNEL_BLD_FLAGS) clean
	$(hide) rm -rf $(KERNEL_OUT_MODINSTALL)

menuconfig xconfig gconfig: $(KERNEL_CONFIG)
	$(hide) $(KERNEL_BLD_ENV) $(MAKE) -C $(KERNEL_SRC_DIR) $(KERNEL_BLD_FLAGS) $@
	$(hide) cp -f $(KERNEL_CONFIG) $(KERNEL_DEFCONFIG)
	$(hide) echo ===========
	$(hide) echo $(KERNEL_DEFCONFIG) has been modified !
	$(hide) echo ===========

build_kernel: $(KERNEL_BZIMAGE)

modules_install: $(KERNEL_OUT_MODINSTALL)

copy_modules_to_root: modules_install
	$(hide) for module in $(KERNEL_MODULES_TO_ROOT); do \
		find $(KERNEL_OUT_MODINSTALL)/lib/modules/`cat $(KERNEL_VERSION_FILE)` -name "$${module}" \
			-exec cp -u {} $(KERNEL_MODULES_ROOT)/ \; ; \
	done

copy_modules_to_system: modules_install
	$(hide) mkdir -p $(KERNEL_MODULES_VENDOR)
	$(hide) for module in $$(find $(KERNEL_OUT_MODINSTALL)/lib/modules/`cat $(KERNEL_VERSION_FILE)` -name "*.ko"); do \
		cp -u "$${module}" $(KERNEL_MODULES_VENDOR)/ ; \
	done

TAGS_files := TAGS
tags_files := tags
gtags_files := GTAGS GPATH GRTAGS GSYMS
cscope_files := $(addprefix cscope.,files out out.in out.po)

TAGS tags gtags cscope: $(KERNEL_CONFIG)
	$(hide) $(KERNEL_BLD_ENV) $(MAKE) -C $(KERNEL_SRC_DIR) $(KERNEL_BLD_FLAGS) $$(hide)
	$(hide) rm -f $(KERNEL_SRC_DIR)/$($@_files)
	$(hide) cp -fs $(addprefix `pwd`/$(KERNEL_OUT_DIR)/,$($@_files)) $(KERNEL_SRC_DIR)/

.PHONY: menuconfig xconfig gconfig
.PHONY: build_kernel build_kernel-nodeps copy_modules_to_root copy_modules_to_system

$(PRODUCT_OUT)/boot.img: build_kernel

$(PRODUCT_OUT)/ramdisk.img: copy_modules_to_root

$(PRODUCT_OUT)/system.img: copy_modules_to_system

endif #TARGET_KERNEL_BUILT_FROM_SOURCE

#
# Copyright (C) 2015 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# This file is executed by build/envsetup.sh, and can use anything
# defined in envsetup.sh.
#
# In particular, you can add lunch options with the add_lunch_combo
# function: add_lunch_combo generic-eng

add_lunch_combo tulip_chiphd-eng
add_lunch_combo tulip_chiphd-user
add_lunch_combo tulip_chiphd_atv-eng
add_lunch_combo tulip_chiphd_atv-user

ninja_tulip() {
	(
		. out/env-$TARGET_PRODUCT.sh
		exec prebuilts/ninja/linux-x86/ninja -C "$(gettop)" -f out/build-$TARGET_PRODUCT.ninja "$@"
	)
}

sdcard_image() {
	if [[ $# -ne 1 ]] && [[ $# -ne 2 ]]; then
		echo "Usage: $0 <output-image> [data-size-in-MB]"
		return 1
	fi

  out_gz="$1"
  out="$(dirname "$out_gz")/$(basename "$out_gz" .gz)"

  get_device_dir

  boot0="$DEVICE/bootloader/boot0.bin"
  uboot="$DEVICE/bootloader/u-boot-with-dtb.bin"
  kernel="$ANDROID_PRODUCT_OUT/kernel"
  ramdisk="$ANDROID_PRODUCT_OUT/ramdisk.img"
  ramdisk_recovery="$ANDROID_PRODUCT_OUT/ramdisk-recovery.img"

  boot0_position=8      # KiB
  uboot_position=19096  # KiB
  part_position=21      # MiB
  boot_size=49          # MiB
  cache_size=768        # MiB
  data_size=${2:-1024}  # MiB
  mbs=$((1024*1024/512)) # MiB to sector

  (
    set -eo pipefail

    echo "Create beginning of disk..."
    dd if=/dev/zero bs=1M count=$part_position of="$out" status=none
    dd if="$boot0" conv=notrunc bs=1k seek=$boot0_position of="$out" status=none
    dd if="$uboot" conv=notrunc bs=1k seek=$uboot_position of="$out" status=none

    echo "Create boot file system... (VFAT)"
    dd if=/dev/zero bs=1M count=${boot_size} of="${out}.boot" status=none
    mkfs.vfat -n BOOT "${out}.boot"

    mcopy -v -m -i "${out}.boot" "$kernel" ::
    mcopy -v -m -i "${out}.boot" "$ramdisk" ::
    mcopy -v -m -i "${out}.boot" "$ramdisk_recovery" ::
    mcopy -v -s -m -i "${out}.boot" "$DEVICE/bootloader/pine64" ::
    cat <<"EOF" > uEnv.txt
console=ttyS0,115200n8
selinux=permissive
optargs=enforcing=0 cma=384M no_console_suspend
kernel_filename=kernel
initrd_filename=ramdisk.img
hardware=sun50iw1p1
EOF

    cat <<"EOF" > boot.script
setenv set_cmdline set bootargs console=${console} ${optargs} androidboot.serialno=${sunxi_serial} androidboot.hardware=${hardware} androidboot.selinux=${selinux} earlyprintk=sunxi-uart,0x01c28000 loglevel=8 root=${root}
run mmcboot
EOF
    mkimage -C none -A arm -T script -d boot.script boot.scr
    mcopy -v -m -i "${out}.boot" "boot.scr" ::
    mcopy -m -i "${out}.boot" "uEnv.txt" ::
    rm -f boot.script boot.scr uEnv.txt

    dd if="${out}.boot" conv=notrunc oflag=append bs=1M of="$out" status=none
    rm -f "${out}.boot"

    echo "Append system..."
    simg2img "$ANDROID_PRODUCT_OUT/system.img" "${out}.system"
    dd if="${out}.system" conv=notrunc oflag=append bs=1M of="$out" status=none
    system_size=$(stat -c%s "${out}.system")
    rm -f "${out}.system"

    echo "Append cache..."
    dd if=/dev/zero bs=1M conv=notrunc oflag=append count="$cache_size" of="$out" status=none

    echo "Append data..."
    dd if=/dev/zero bs=1M conv=notrunc oflag=append count="$data_size" of="$out" status=none

    echo "Partition table..."
    cat <<EOF | sfdisk "$out"
$((part_position*mbs)),$((boot_size*mbs)),6
$(((part_position+boot_size)*mbs)),$((system_size/512)),L
$(((part_position+boot_size)*mbs+system_size/512)),$((cache_size*mbs)),L
$(((part_position+boot_size)*mbs+system_size/512)),$((data_size*mbs)),L
EOF

    echo "Updating fastboot table..."
    sunxi-nand-part -f a64 "$out" $(((part_position-20)*mbs)) \
      "boot $((boot_size*mbs)) 32768" \
      "system $((system_size/512)) 32768" \
      "cache $((cache_size*mbs)) 32768" \
      "data 0 33024"

    size=$(stat -c%s "$out")

    if [[ "$(basename "$out_gz" .gz)" != "$(basename "$out_gz")" ]]; then
      gzip "$out"
      echo "Compressed image: $out (size: $size)."
    else
      echo "Uncompressed image: $out (size: $size)."
    fi
  )
}

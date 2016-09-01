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


SDCARD_BLOCK_SIZE=512

sdcard_command() {
	echo -n "$1 " 1>&2
	shift
	if eval "$@"; then
		echo "success" 1>&2
		return 0
	else
		echo "failed" 1>&2
		return 1
	fi
}

sdcard_file_size() {
	stat -c%s "$1" 2>/dev/null
}

sdcard_append_file() {
	IN_SIZE="$(sdcard_file_size $2)" &&
	MAX_IN_SIZE="$(($3*$SDCARD_BLOCK_SIZE))" &&
	sdcard_command "Validating a size of $(basename $2)..." "test $IN_SIZE -le $MAX_IN_SIZE" &&
	sdcard_command "Appending $(basename $2) of $IN_SIZE..." dd if="$2" of="$1" bs=$SDCARD_BLOCK_SIZE count="$3" oflag=append conv=notrunc status=none &&
	( [[ $MAX_IN_SIZE == $IN_SIZE ]] || sdcard_command "Aligning $(basename $2)..." dd if="$2" of="$1" bs="$((MAX_IN_SIZE-$IN_SIZE))" count="1" oflag=append conv=notrunc status=none )
}

sdcard_append_size() {
	sdcard_command "Appending zero-space $2..." dd if=/dev/zero of="$1" bs="$SDCARD_BLOCK_SIZE" count="$3" oflag=append conv=notrunc status=none
}

sdcard_append_mkfs4() {
	file="$ANDROID_PRODUCT_OUT/$2.raw.img"
	sdcard_command "Creating $2..." fallocate -l "$(($3*$SDCARD_BLOCK_SIZE))" "$file" &&
	sdcard_command "Formatting $2..." mkfs.ext4 -q "$file" &&
	sdcard_append_file "$1" "$file" "$3"
	result="$?"
	rm "$file" 2>/dev/null
	return $result
}

sdcard_append_vfat() {
	file="$ANDROID_PRODUCT_OUT/$2.raw.img"
	sdcard_command "Creating $2..." fallocate -l "$(($3*$SDCARD_BLOCK_SIZE))" "$file" &&
	sdcard_command "Formatting $2..." mkfs.vfat "$file" &&
	sdcard_append_file "$1" "$file" "$3"
	result="$?"
	rm "$file" 2>/dev/null
	return $result
}

sdcard_append_system() {
	sdcard_command "Unpacking system partition..." simg2img "$ANDROID_PRODUCT_OUT/system.img" "$ANDROID_PRODUCT_OUT/system.raw.img" &&
	sdcard_append_file "$1" "$ANDROID_PRODUCT_OUT/system.raw.img" "$2"
	result="$?"
	rm "$ANDROID_PRODUCT_OUT/system.raw.img" 2>/dev/null
	return $result
}

sdcard_init_bootloader() {
	sdcard_command "Unpacking bootloader..." gunzip -c "$DEVICE/bootloader/bootloader.img.gz"
}

sdcard_create_image() {
	sdcard_init_bootloader &&
	sdcard_append_file "$1" "$ANDROID_PRODUCT_OUT/boot.img" 32768 &&
	sdcard_append_system "$1" 3145728 &&
	sdcard_append_size "$1" misc 32768 &&
	sdcard_append_file "$1" "$ANDROID_PRODUCT_OUT/recovery.img" 65536 &&
	sdcard_append_mkfs4 "$1" cache 1572864 &&
	sdcard_append_size "$1" metadata 32768 &&
	sdcard_append_vfat "$1" private 32768 &&
	sdcard_append_mkfs4 "$1" alog 163840 &&
	sdcard_append_mkfs4 "$1" UDISK 9943039
}

sdcard_image() {
	if [[ $# -ne 1 ]]; then
		echo "Usage: $0 <output-image>"
		return 1
	fi

	if [[ -z "$ANDROID_PRODUCT_OUT" ]]; then
		echo "Define ANDROID_PRODUCT_OUT"
		return 1
	fi

	get_device_dir

	if  sdcard_create_image "/dev/stdout" | gzip -c > "$1"
	then
		echo "Done: $1"
		return 0
	else
		return 1
	fi
}

ninja_tulip() {
	prebuilts/ninja/linux-x86/ninja -C "$(gettop)" -f out/build-tulip_chiphd.ninja "$@"
}

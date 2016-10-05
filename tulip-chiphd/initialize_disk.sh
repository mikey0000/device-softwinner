#!/bin/sh

exec 1> /dev/kmsg
exec 2> /dev/kmsg

BB=/sbin/busybox
DISK=/dev/block/mmcblk0
PART_NO=4
DISK_PART=${DISK}p${PART_NO}

CYLINDERS=$(${BB} fdisk -l $DISK | ${BB} grep heads | ${BB} awk '{print $5}')
START_DISK=$(${BB} fdisk -l $DISK | ${BB} grep ${DISK_PART} | ${BB} awk '{print $2}')
END_DISK=$(${BB} fdisk -l $DISK | ${BB} grep ${DISK_PART} | ${BB} awk '{print $3}')

if [ -z "$CYLINDERS" ] || [ -z "$START_DISK" ] || [ -z "$END_DISK" ]; then
  echo "Missing fdisk data"
  ${BB} fdisk -l $DISK
  exit 4
fi

FDISK_SCRIPT="d
${PART_NO}
n
p
${START_DISK}
${CYLINDERS}
w
p
"

if [ "${END_DISK}" != "${CYLINDERS}" ]; then
  # Create partitions
  if ! echo "$FDISK_SCRIPT" | ${BB} fdisk ${DISK}; then
    echo "Failed to update mmcblk0 with fdisk"
    exit 1
  fi
else
  echo "$DISK_PART: is $START_DISK to $END_DISK of $CYLINDERS"
fi

# Mount system
if ! ${BB} mount -t ext4 -o ro,barrier=1 ${DISK}p2 /system; then
  echo "Failed to mount /system"
  exit 2
fi

# Nothing to do?
if /system/bin/resize2fs ${DISK_PART} 2>&1 | ${BB} grep "Nothing to do"; then
  echo "Disk is already resized"
  exit 0
fi

# Check partition
/system/bin/e2fsck -p -f ${DISK_PART}

# Resize partition
if ! /system/bin/resize2fs ${DISK_PART}; then
  echo "Failed to resize /data"
  exit 3
fi

echo "Disk is resized"

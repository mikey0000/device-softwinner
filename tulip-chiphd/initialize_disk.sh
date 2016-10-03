#!/bin/sh

if [ -e /dev/block/mmcblk0p3 ] || [ -e /dev/block/mmcblk0p4 ]; then
  exit 0
fi

# Create partitions
echo "n
p
3
67777
92352
p
n
p
92353

w
p
" | /sbin/busybox fdisk /dev/block/mmcblk0

# Re-read partitions
/sbin/busybox blockdev --rereadpt /dev/block/mmcblk0

# Force to format partitions
for i in 1 2 3 4 5 6 7 8 9 10; do
  if [ -e /dev/block/mmcblk0p3 ]; then
    /sbin/busybox dd if=/dev/zero of=/dev/block/mmcblk0p3 bs=1048576 count=1
    break
  fi
  /sbin/busybox sleep 1s
done

for i in 1 2 3 4 5 6 7 8 9 10; do
  if [ -e /dev/block/mmcblk0p4 ]; then
    /sbin/busybox dd if=/dev/zero of=/dev/block/mmcblk0p4 bs=1048576 count=1
    break
  fi
  /sbin/busybox sleep 1s
done

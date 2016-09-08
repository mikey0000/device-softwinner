#!/sbin/busybox sh

BUSYBOX="/sbin/busybox"

if [ ! -e /data/system.notfirstrun ] ; then
    echo "do preinstall job"

    for i in /system/preinstall/*.apk; do
      /system/bin/pm installl $i
    done

    $BUSYBOX touch /data/system.notfirstrun

    echo "preinstall ok"
fi

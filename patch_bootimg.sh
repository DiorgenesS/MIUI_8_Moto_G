#!/bin/bash

BOOTIMG=$1

# Unpack bootimg
rm -rf $TARGET_BOOT_DIR
mkdir -p $TARGET_BOOT_DIR
$UNPACKBOOTIMG -i $BOOTIMG -o $TARGET_BOOT_DIR > /dev/null

# Unpack ramdisk
gunzip $TARGET_BOOT_DIR/boot.img-ramdisk.gz
mkdir -p $TARGET_BOOT_DIR/ramdisk
cd $TARGET_BOOT_DIR/ramdisk
cpio -i < ../boot.img-ramdisk
cd - > /dev/null

# ramdisk miui
if [ -d overlay/boot/ramdisk ];then
cp -rf overlay/boot/ramdisk/* $TARGET_BOOT_DIR/ramdisk/
fi

# repack ramdisk
$MKBOOTFS $TARGET_BOOT_DIR/ramdisk | gzip > $TARGET_BOOT_DIR/ramdisk.gz


# Disable selinux
OLDCMDLINE=$(cat $TARGET_BOOT_DIR/boot.img-cmdline)
NEWCMDLINE="androidboot.selinux=permissive"
for prop in $OLDCMDLINE
do
    echo $prop | grep "androidboot.selinux=" > /dev/null
    if [ $? -eq 0 ];then
        continue
    fi
    NEWCMDLINE="$NEWCMDLINE $prop"
done

echo "NEWCMDLINE: $NEWCMDLINE"

BASEADDR=$(cat $TARGET_BOOT_DIR/boot.img-base)
PAGESIZE=$(cat $TARGET_BOOT_DIR/boot.img-pagesize)
RAMDISKOFFSET=$(cat $TARGET_BOOT_DIR/boot.img-ramdisk_offset)
TAGSOFFSET=$(cat $TARGET_BOOT_DIR/boot.img-tags_offset)

# repack bootimg
$MKBOOTIMG --kernel $TARGET_BOOT_DIR/boot.img-zImage --ramdisk $TARGET_BOOT_DIR/ramdisk.gz --dt $TARGET_BOOT_DIR/boot.img-dt --base "$BASEADDR" --pagesize "$PAGESIZE" --ramdisk_offset "$RAMDISKOFFSET" --tags_offset "$TAGSOFFSET" --cmdline "$NEWCMDLINE" -o $BOOTIMG

#!/bin/bash

selectsdcard() {
    echo "##############################################"
    echo "# Choose your SD card                        #"
    echo "##############################################"
    lsblk -dn -o NAME,SIZE
    while true; do
        echo "# Device to format: "
        read SDCARD
        echo "selected: $SDCARD"
        if lsblk -dn -o NAME | grep "$SDCARD"; then
            
            break;
        else
            echo "Device not supported... retry"
        fi
    done
    echo "##############################################"
    echo "# using card [$SDCARD]"
    echo "##############################################"
    echo ""
}

createPartitions() {
    selectsdcard


    echo "##############################################"
    echo "# making partitions                          #"
    echo "##############################################"
    sudo ../sources/meta-bbb/scripts/mk2parts.sh $SDCARD
}

writePartitions() {
    selectsdcard

    echo "##############################################"
    echo "# making preparations                        #"
    echo "##############################################"
    MOUNTDIR="/media/card"
    if [ ! -d "$MOUNTDIR" ]; then
        echo "Creating directory $MOUNTDIR"
        sudo mkdir "$MOUNTDIR"
    else
        echo "Using $MOUNTDIR"
        umount "/media/card"
    fi	

    echo "exporting variables"
    YOCTOTEMPDIR=${PWD}
    export OETMP="$YOCTOTEMPDIR"
    export MACHINE=beaglebone

    echo "unmounting stuff"
    PART1="/dev/$SDCARD""p1"
    PART2="/dev/$SDCARD""p2"
    umount $PART1
    umount $PART2

    echo "##############################################"
    echo "# copy boot partition                        #"
    echo "##############################################"
    ../sources/meta-bbb/scripts/copy_boot.sh $SDCARD

    echo "##############################################"
    echo "# copy boot partition                        #"
    echo "##############################################"
    IMAGENAME="console"
    HOSTNME="bbbmbed"
    ../sources/meta-bbb/scripts/copy_rootfs.sh $SDCARD $IMAGENAME $HOSTNME
}
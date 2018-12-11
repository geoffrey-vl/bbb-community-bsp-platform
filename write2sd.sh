#!/bin/bash

IMAGENAME="console"
HOSTNME="bbbmbed"

selectsdcard() {
    while true; do
        echo "List of devices: "
        lsblk -dn -o NAME,SIZE
        echo "Device to format: "
        read SDCARD
        return
        echo "selected: $SDCARD"
        if lsblk -dn -o NAME | grep "$SDCARD"; then
            break
        else
            echo "Device not supported... retry"
        fi
    done
    echo "using card [$SDCARD]"
    echo ""
}

selectImage() {
	echo "List of images: "
	echo "console"
	echo "mbed-cloud-client-example-nofwup"
	echo "Enter the image to select: "
	read IMAGENAME
    echo "using image [$IMAGENAME]"
    echo ""
}

getTempBuildFolder()
{
    CURRDIR=${PWD}
    cd "$SCRIPTLOCATION"
    cd "../../build/tmp"
    YOCTOTEMPDIR=${PWD}
    cd "$CURRDIR"
}

setupTempMountFolder()
{
    MOUNTDIR="/media/write2sdmountfolder"
    if [ ! -d "$MOUNTDIR" ]; then
        echo "Creating directory $MOUNTDIR"
        sudo mkdir "$MOUNTDIR"
    else
        echo "Using $MOUNTDIR"
        umount "$MOUNTDIR"
    fi	

    echo "exporting variables"
    export OETMP="$YOCTOTEMPDIR"
    export MACHINE=beaglebone

    echo "unmounting stuff"
    PART1="/dev/$SDCARD""p1"
    PART2="/dev/$SDCARD""p2"
    umount $PART1
    umount $PART2
}

createPartitions() {
    echo "# creating partitions..."
    sudo ../sources/meta-bbb/scripts/mk2parts.sh $SDCARD
}

writeBootPartition()
{
    echo "# copying eEnv..."
    cp ../sources/meta-bbb/scripts/uEnv.txt-example $YOCTOTEMPDIR/deploy/images/beaglebone/uEnv.txt
    echo "# copying boot partition..."
    ../sources/meta-bbb/scripts/copy_boot.sh $SDCARD
}

writeRootFsPartition()
{
    echo "# copying rootfs partition..."
    ../sources/meta-bbb/scripts/copy_rootfs.sh $SDCARD $IMAGENAME $HOSTNME
}


showMainMenu()
{
    while true; do
        echo "# Menu options: "
        echo "# 1. create partitions"
        echo "# 2. write boot partition"
        echo "# 3. write rootfs partition"
        echo "# 4. quit"
        echo "# Select task (1...4): "
        read MENUITEM
        echo "selected: $MENUITEM"
        if [ "$MENUITEM" -lt 1 ] || [ "$MENUITEM" -gt 4 ] ; then
            echo "illegal option... retry"   
        elif [ "$MENUITEM" -eq "1" ]; then
            createPartitions
        elif [ "$MENUITEM" -eq "2" ]; then
            writeBootPartition
        elif [ "$MENUITEM" -eq "3" ]; then
            writeRootFsPartition
        else
            echo "exiting..."
            break
        fi
    done
}


echo "##############################################"
echo "# Write2SD                                   #"
echo "##############################################"
SCRIPTLOCATION="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
echo "Script location: $SCRIPTLOCATION"
getTempBuildFolder
echo "Yocto build temp location: $YOCTOTEMPDIR"

selectsdcard
selectImage
setupTempMountFolder

showMainMenu

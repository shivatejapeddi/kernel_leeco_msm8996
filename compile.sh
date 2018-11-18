#!/bin/bash

# Bash Color
green='\033[01;32m'
red='\033[01;31m'
blink_red='\033[05;31m'
restore='\033[0m'

clear

# Resources
THREAD="-j$(grep -c ^processor /proc/cpuinfo)"
KERNEL="Image.gz-dtb"
DTBIMAGE="dtb"
DEFCONFIG="msm-perf_defconfig"
KERNEL_DIR=`pwd`
RESOURCE_DIR="$KERNEL_DIR/.."
ANYKERNEL_DIR="${HOME}/anykernel"
TOOLCHAIN_DIR="${HOME}/toolchain"

# Kernel Details
BASE_AMIGOS_VER="Amigos.x2.Unified"
VER="."stable1.0
AMIGOS_VER="$BASE_AMIGOS_VER$VER"

# Vars
export LOCALVERSION=-`echo $AMIGOS_VER`
export CROSS_COMPILE="$TOOLCHAIN_DIR/aarch64-linux-android-4.9/bin/aarch64-linux-android-"
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER=Dabug123
export KBUILD_BUILD_HOST=Derpbox

# Paths
REPACK_DIR="$ANYKERNEL_DIR"
PATCH_DIR="$ANYKERNEL_DIR/patch"
MODULES_DIR="$ANYKERNEL_DIR/modules"
ZIP_MOVE="${HOME}/kernel/eui"
ZIMAGE_DIR="${HOME}/kernel/eui/arch/arm64/boot"

# Functions
function clean_all {
		if [ -f "$MODULES_DIR/*.ko" ]; then
			rm `echo $MODULES_DIR"/*.ko"`
		fi
		cd $REPACK_DIR
		rm -rf $KERNEL
		rm -rf $DTBIMAGE
		cd $KERNEL_DIR
		echo
		make clean && make mrproper
}

function make_kernel {
		echo
		make $DEFCONFIG
		make $THREAD
		cp -vr $ZIMAGE_DIR/$KERNEL $REPACK_DIR/zImage
}

function make_modules {
		if [ -f "$MODULES_DIR/*.ko" ]; then
			rm `echo $MODULES_DIR"/*.ko"`
		fi
		#find $MODULES_DIR/proprietary -name '*.ko' -exec cp -v {} $MODULES_DIR \;
		find $KERNEL_DIR -name '*.ko' -exec cp -v {} $MODULES_DIR \;
}

function make_zip {
		cd $REPACK_DIR
		zip -r9 `echo $AMIGOS_VER`.zip *
		mv  `echo $AMIGOS_VER`.zip $ZIP_MOVE
		cd $KERNEL_DIR
}


DATE_START=$(date +"%s")

echo -e "${green}"
echo "amigos Core Creation Script:"
echo

echo "---------------"
echo "amigos Version:"
echo "---------------"

echo -e "${red}"; echo -e "${blink_red}"; echo "$AMIGOS_VER"; echo -e "${restore}";

echo -e "${green}"
echo "-----------------"
echo "Making amigos Kernel:"
echo "-----------------"
echo -e "${restore}"

while read -p "Do you want to clean stuffs (y/n)? " cchoice
do
case "$cchoice" in
	y|Y )
		clean_all
		echo
		echo "All Cleaned now."
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo

while read -p "Do you want to build kernel (y/n)? " dchoice
do
case "$dchoice" in
	y|Y)
		make_kernel
		make_modules
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo

while read -p "Do you want to ZIP kernel (y/n)? " dchoice
do
case "$dchoice" in
	y|Y)
		make_zip
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo -e "${green}"
echo "-------------------"
echo "Build Completed in:"
echo "-------------------"
echo -e "${restore}"

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo


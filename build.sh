#!/bin/bash

ROOT_DIR=$(cd $(dirname $0); pwd)
source ${ROOT_DIR}/scripts-common/helpers

variant="userdebug"

#export ALLOW_MISSING_DEPENDENCIES=true

#https://android.googlesource.com/platform/build/+/master/Changes.md#PATH_Tools
#export TEMPORARY_DISABLE_PATH_RESTRICTIONS=true
export USE_CCACHE=1

TARGET_USERDATAIMAGE_4GB=false
USE_SQUASHFS=false
VTS=false
CTS=false
MMMA=false
unset TARGETS
unset SHOW_COMMANDS

version="master"
board="hikey"

function build(){
    #export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
    #export PATH=${JAVA_HOME}/bin:$PATH

    if [ -n "${HOOK_PRE_ANDROID_BUILD}" ] && [ "$MMMA" = false ]; then
	echo "Start ${HOOK_PRE_ANDROID_BUILD}:" >>logs/time.log
	date +%Y%m%d-%H%M >>logs/time.log
	echo "(time ./android-build-configs/hooks/${HOOK_PRE_ANDROID_BUILD}) 2>&1 |tee logs/build-${board}.log"
	(time ./android-build-configs/hooks/${HOOK_PRE_ANDROID_BUILD}) 2>&1 |tee logs/build-${board}.log
	echo "Build done!"
	date +%Y%m%d-%H%M >>logs/time.log
    fi

    echo "source build/envsetup.sh" 2>&1 |tee logs/build-${board}.log
    source build/envsetup.sh
    echo "lunch ${board}-${variant}" 2>&1 |tee logs/build-${board}.log
    lunch ${board}-${variant}

    if [ "$MMMA" = true ]; then
	echo "Start to build ${DIR1}:" >>logs/time.log
	date +%Y%m%d-%H%M >>logs/time.log
	echo "(time LANG=C mmma ${DIR1}) 2>&1 |tee logs/build-${board}.log"
	(time LANG=C mmma ${DIR1}) 2>&1 |tee logs/build-${board}.log
	echo "Build done!"
	date +%Y%m%d-%H%M >>logs/time.log
	exit
    fi

    echo "Start to build:" >>logs/time.log
    date +%Y%m%d-%H%M >>logs/time.log
    echo "(time LANG=C make ${TARGETS[@]} -j${CPUS} ${SHOW_COMMANDS}) 2>&1 |tee logs/build-${board}.log"
    (time LANG=C make ${TARGETS[@]} -j${CPUS} ${SHOW_COMMANDS}) 2>&1 |tee logs/build-${board}.log
    echo "Build done!"
    date +%Y%m%d-%H%M >>logs/time.log

    if [ -n "${HOOK_POST_ANDROID_BUILD}" ]; then
	echo "Start ${HOOK_POST_ANDROID_BUILD}:" >>logs/time.log
	date +%Y%m%d-%H%M >>logs/time.log
	echo "(time ./android-build-configs/hooks/${HOOK_POST_ANDROID_BUILD}) 2>&1 |tee logs/build-${board}.log"
	(time ./android-build-configs/hooks/${HOOK_POST_ANDROID_BUILD}) 2>&1 |tee logs/build-${board}.log
	echo "Build done!"
	date +%Y%m%d-%H%M >>logs/time.log
    fi

    if $VTS; then
	echo "Start VTS build:" >>logs/time.log
	date +%Y%m%d-%H%M >>logs/time.log
	echo "(time LANG=C make vts -j${CPUS} ${SHOW_COMMANDS}) 2>&1 |tee logs/build-${board}.log"
	(time LANG=C make vts -j${CPUS} ${SHOW_COMMANDS}) 2>&1 |tee logs/build-${board}.log
	echo "VTS build done!"
	date +%Y%m%d-%H%M >>logs/time.log
    fi

    if $CTS; then
	echo "Start CTS build:" >>logs/time.log
	date +%Y%m%d-%H%M >>logs/time.log
	echo "(time LANG=C make cts -j${CPUS} ${SHOW_COMMANDS}) 2>&1 |tee logs/build-${board}.log"
	(time LANG=C make cts -j${CPUS} ${SHOW_COMMANDS}) 2>&1 |tee logs/build-${board}.log
	echo "CTS build done!"
	date +%Y%m%d-%H%M >>logs/time.log
    fi
}

function build_hikey(){
    cd ${ROOT_DIR} #is this necessary?
    export TARGET_BUILD_KERNEL=true
    export TARGET_BOOTIMAGE_USE_FAT=true
    # settings for optee
    export TARGET_TEE_IS_OPTEE=true
    export TARGET_BUILD_UEFI=true
    #we need to set an OP-TEE's CFG_* flag ONLY IF it's used in an
    #Android.mk somewhere!
    export CFG_SECURE_DATA_PATH=y
    export CFG_SECSTOR_TA_MGMT_PTA=y
    export CFG_TA_DYNLINK=y
    board=hikey
    build
    echo "HiKey build done!"
}

clean_build() {
    echo -e "\nINFO: Removing entire out dir. . .\n"
    echo "make -j${CPUS} ${SHOW_COMMANDS} clobber"
    make -j${CPUS} ${SHOW_COMMANDS} clobber
}

##########################################################
##########################################################
while [ "$1" != "" ]; do
	case $1 in
		-4g)
			echo "Set 4GB board"
			export TARGET_USERDATAIMAGE_4GB=true
			;;
		-b | --build-target)
			shift
			echo "Adding build target: $1"
			TARGETS=(${TARGETS[@]} $1)
			;;
		-cts)
			echo "Build CTS"
			CTS=true
			;;
		-d)	# overwrite dbg in helpers
			echo "Print debug"
			dbg=true
			SHOW_COMMANDS=showcommands
			;;
		-j)     # set build parallellism
			# overwrite CPUS in helpers
			shift
			echo "Num threads: $1"
			CPUS=$1
			;;
		-mmma)	shift
			MMMA=true
			DIR1=$1
			;;
		-squashfs)
			echo "Use squashfs for system img"
			USE_SQUASHFS=true
			;;
		-t)     # overwrite board above
			# default is hikey
			# no other eg atm
			shift
			echo "board=$1"
			board=$1
			;;
		-v)     # overwrite version above
			# default is master
			# eg o or p
			shift
			echo "version=$1"
			version=$1
			;;
		-vts)
			echo "Build VTS"
			VTS=true
			;;
		-wv)	#overwrite wv in helpers
			echo "wv build"
			wv=true
			;;
                *)	# default adds to target list without shift
                        echo "Adding build target by default: $1"
                        TARGETS=(${TARGETS[@]} $1)
                        ;;
	esac
	shift
done

export_config
echo "Overwrite TARGET_SYSTEMIMAGES_USE_SQUASHFS=true in android-build-configs (abc)!"
echo "export TARGET_SYSTEMIMAGES_USE_SQUASHFS=$USE_SQUASHFS"
export TARGET_SYSTEMIMAGES_USE_SQUASHFS=$USE_SQUASHFS
#echo "Set TARGET_BOOTIMAGE_USE_FAT to false for now due to fat16copy error"
#alternatively try mcopy
#see https://github.com/vchong/device-linaro-hikey/commit/fcfe2d6ac00539f2d4cf77295503c0d285ee8170
echo "export TARGET_BOOTIMAGE_USE_FAT=true"
export TARGET_BOOTIMAGE_USE_FAT=true
echo ""
build ${board}
echo "Please make sure there are no errors before flashing!"

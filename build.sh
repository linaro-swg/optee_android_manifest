#!/bin/bash

ROOT_DIR=$(cd $(dirname $0); pwd)
source ${ROOT_DIR}/scripts-common/helpers

variant="userdebug"

#export ALLOW_MISSING_DEPENDENCIES=true

#https://android.googlesource.com/platform/build/+/master/Changes.md#PATH_Tools
#export TEMPORARY_DISABLE_PATH_RESTRICTIONS=true
export USE_CCACHE=1

USE_SQUASHFS=false

function build(){
    #export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
    #export PATH=${JAVA_HOME}/bin:$PATH
    product="${1}"
    if [ -z "${product}" ]; then
	echo "Please specify target board"
	return
    fi
    source build/envsetup.sh
    lunch ${product}-${variant}

    echo "Start to build:" >>logs/time.log
    date +%Y%m%d-%H%M >>logs/time.log
    echo "(time LANG=C make ${TARGETS[@]} -j${CPUS} ${SHOW_COMMANDS}) 2>&1 |tee logs/build-${product}.log"
    (time LANG=C make ${TARGETS[@]} -j${CPUS} ${SHOW_COMMANDS}) 2>&1 |tee logs/build-${product}.log
    date +%Y%m%d-%H%M >>logs/time.log
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
    build hikey
    echo "HiKey build done!"
    if $CTS; then
	if $dbg; then
		echo "CPUS=${CPUS}"
	fi
	echo "Building CTS.."
	make -j${CPUS} ${SHOW_COMMANDS} cts
	echo "CTS build done!"
    fi
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
		-j)     # set build parallellism
			shift
			echo "Num threads: $1"
			CPUS=$1
			;;
		-4g)
			echo "Set 4GB board"
			export TARGET_USERDATAIMAGE_4GB=true
			;;
		-squashfs)
			echo "Use squashfs for system img"
			USE_SQUASHFS=true
			;;
		-cts)
			echo "Build CTS"
			CTS=true
			;;
		-b | --build-target)
			shift
			echo "Adding build target: $1"
			TARGETS=(${TARGETS[@]} $1)
			;;
		-d)
			echo "Print debug"
			dbg=true
			SHOW_COMMANDS=showcommands
			;;
                *)	# default adds to target list without shift
                        echo "Adding build target by default: $1"
                        TARGETS=(${TARGETS[@]} $1)
                        ;;
	esac
	shift
done

export_config hikey o
echo "Overwrite TARGET_SYSTEMIMAGES_USE_SQUASHFS=true in android-build-configs (abc)!"
echo "export TARGET_SYSTEMIMAGES_USE_SQUASHFS=$USE_SQUASHFS"
export TARGET_SYSTEMIMAGES_USE_SQUASHFS=$USE_SQUASHFS
build ${TARGET_PRODUCT}
echo ""
echo ""
echo "SUCCESS!"

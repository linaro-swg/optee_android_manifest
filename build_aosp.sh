#!/bin/bash

set -e

INIT=true
#CPUS=${CPUS:-$(grep processor /proc/cpuinfo |wc -l)}
CPUS=1
ROOT_DIR=$(cd $(dirname $0); pwd)

variant="userdebug"

export SHOW_COMMANDS=showcommands
#export ALLOW_MISSING_DEPENDENCIES=true
#https://android.googlesource.com/platform/build/+/master/Changes.md#PATH_Tools
#TEMPORARY_DISABLE_PATH_RESTRICTIONS=true

function patch(){
    echo "Applying patches"
    ./android-patchsets/hikey-o-workarounds
    ./android-patchsets/O-RLCR-PATCHSET
    ./android-patchsets/hikey-optee-o
    ./android-patchsets/hikey-optee-4.9
    ./android-patchsets/OREO-BOOTTIME-OPTIMIZATIONS-HIKEY
    ./android-patchsets/optee-master-workarounds
    ./android-patchsets/swg-mods-o
}

function build(){
    #export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
    #export PATH=${JAVA_HOME}/bin:$PATH
    product="${1}"
    if [ -z "${product}" ]; then
	echo "Please specify target board"
        return
    fi

    #patch
    if [ "$INIT" = "true" ]; then
	source build/envsetup.sh
	lunch ${product}-${variant}
    fi

    echo "Start to build:" >>time.log
    date +%Y-%m-%d_%H:%M >>time.log
    echo "(time LANG=C make ${TARGETS[@]} -j${CPUS}) 2>&1 |tee build-${product}.log"
    (time LANG=C make ${TARGETS[@]} -j${CPUS} ) 2>&1 |tee build-${product}.log
    date +%Y-%m-%d_%H:%M >>time.log
}

function build_hikey(){
    cd ${ROOT_DIR}
    export USE_CCACHE=1
    export TARGET_BUILD_KERNEL=true
    export TARGET_BOOTIMAGE_USE_FAT=true
    # settings for optee
    export TARGET_TEE_IS_OPTEE=true
    export TARGET_BUILD_UEFI=true
    export CFG_SECURE_DATA_PATH=y
    export CFG_SECSTOR_TA_MGMT_PTA=y
    export CFG_TA_MBEDTLS_SELF_TEST=y
    export CFG_TA_DYNLINK=y
    build hikey
}

clean_build() {
    echo -e "\nINFO: Removing entire out dir. . .\n"
    make clobber
}

while [ "$1" != "" ]; do
	case $1 in
		-j)     # set build parallellism
			shift
			echo "Num threads: $1"
			CPUS=$1
			;;
		--do-init)
			echo "Do init"
			INIT=true
			;;
		--no-init)
			echo "Skip init"
			INIT=false
			;;
		-4g)
			echo "Set 4GB board"
			export TARGET_USERDATAIMAGE_4GB=true
			;;
		-squashfs)
			echo "Use squashfs for system img"
			export TARGET_SYSTEMIMAGES_USE_SQUASHFS=true
			;;
		-b | --build-target)
			shift
			echo "Adding Build target: $1"
			TARGETS=(${TARGETS[@]} $1)
			;;
                *)	# default adds to target list without shift
                        echo "Adding Build target: $1"
                        TARGETS=(${TARGETS[@]} $1)
                        ;;
	esac
	shift
done

build_hikey

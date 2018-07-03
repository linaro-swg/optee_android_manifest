#!/bin/bash
CPUS=$(grep processor /proc/cpuinfo |wc -l)
#CPUS=1
ROOT_DIR=$(cd $(dirname $0); pwd)

targets="droidcore"
#targets="selinuxtarballs"
#targets="boottarball"
variant="userdebug"

#export CFG_GP_SOCKETS=n
#export INCLUDE_STLPORT_FOR_MASTER=true
#export INCLUDE_LAVA_HACK_FOR_MASTER=true
#export TARGET_GCC_VERSION_EXP=6.3-linaro
#export USE_CLANG_PLATFORM_BUILD=false
#export WITH_DEXPREOPT=true
#export MALLOC_IMPL=dlmalloc
#export MALLOC_IMPL_MUSL=true
export TARGET_BUILD_JAVA_SUPPORT_LEVEL=platform


function build(){
    export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
    export PATH=${JAVA_HOME}/bin:$PATH
    product="${1}"
    if [ -z "${product}" ]; then
        return
    fi
    source build/envsetup.sh
    lunch ${product}-${variant}

    echo "Start to build:" >>time.log
    date +%Y-%m-%d-%H-%M >>time.log
    (time make ${targets} -j${CPUS} showcommands) 2>&1 |tee build-${product}.log
    date +%Y-%m-%d-%H-%M >>time.log
}

function build_juno(){
    export PDK_FUSION_PLATFORM_ZIP=vendor/pdk/mini_arm64/mini_arm64-userdebug/platform/platform.zip
    targets="droidcore boottarball"
    export TARGET_BUILD_KERNEL=true
    build juno
    #targets="selinuxtarballs"
    bz2_dir=${ROOT_DIR}/out/target/product/juno/
    /development/srv/linaro-image-tools/linaro-android-media-create --image_file juno.img --dev vexpress --boot ${bz2_dir}/boot.tar.bz2 --systemimage ${bz2_dir}/system.img --userdataimage ${bz2_dir}/userdata.img
    bzip2 -9 ${bz2_dir}/juno.img
}
function build_db410c(){
    targets="droid"
    build db410c
    targets="selinuxtarballs"
}
function build_x20(){
    targets="droid"
    export TARGET_BUILD_KERNEL=true
    export TARGET_GCC_VERSION_EXP=6.3-linaro
    build full_amt6797_64_open
    targets="selinuxtarballs"
}

######################
# Build clang master #
######################
function build_llvm() {
    LLVM_SRC=${ROOT_DIR}/clang-src/llvm
    rm -fr ${LLVM_SRC}/.git/svn
    rm -fr ${LLVM_SRC}/tools/clang/.git/svn
    LLVM_BUILD_DIR="${ROOT_DIR}/out/target/product/hikey/clang"
    mkdir -p "${LLVM_BUILD_DIR}"
    cd ${LLVM_BUILD_DIR}
    cmake -G "Unix Makefiles" ${LLVM_SRC} \
             -DCMAKE_BUILD_TYPE=Release \
             -DPYTHON_EXECUTABLE=/usr/bin/python2 \
             -DCMAKE_INSTALL_PREFIX=${ROOT_DIR}/prebuilts/clang/host/linux-x86/clang-master \
             -DLLVM_TARGETS_TO_BUILD="ARM;X86;AArch64"

             #-O ${LLVM_BUILD_DIR} \

    make install VERBOSE=1 -j16 #-j$CPUs #too many n of cpus
}

#########
# Setup #
#########
function setup_for_clang_upstream() {
    # Adapt to the aosp toolchain folder hierarchy
    ANDROID_CLANGVER=$(awk '{ if ($1 == "LLVM_PREBUILTS_VERSION") print $3 }' ${ROOT_DIR}/build/core/clang/versions.mk)
    [ -z $ANDROID_CLANGVER ] && ANDROID_CLANGVER=clang-3217047 # aosp prebuilt build number at 2016/10/20 master

    CLANG_MASTER_DIR="$ROOT_DIR/prebuilts/clang/host/linux-x86/clang-master/"
    CLANG_AOSP_DIR="$ROOT_DIR/prebuilts/clang/host/linux-x86/${ANDROID_CLANGVER}/"
    # 1. Handle libFuzzer.a and its headers
    for i in host arm aarch64 i386 x86_64 mips; do
        mkdir -p ${CLANG_MASTER_DIR}/lib64/clang/5.0/lib/linux/$i
        cp -a ${CLANG_AOSP_DIR}/lib64/clang/5.0/lib/linux/$i/libFuzzer.a ${CLANG_MASTER_DIR}/lib64/clang/5.0/lib/linux/$i
    done
    mkdir -p ${CLANG_MASTER_DIR}/prebuilt_include/llvm/lib/Fuzzer
    cp -af  ${CLANG_AOSP_DIR}/prebuilt_include/llvm/lib/Fuzzer/*.h ${CLANG_MASTER_DIR}/prebuilt_include/llvm/lib/Fuzzer

    # 2. Handle missing modules from Upstream clang
    cp -af  ${CLANG_AOSP_DIR}/test ${CLANG_MASTER_DIR}/test
}

function build_hikey(){
    #export BUILD_CLANG_MASTER=true
    export BUILD_CLANG_MASTER=false
    if ${BUILD_CLANG_MASTER}; then
        export LLVM_PREBUILTS_VERSION=clang-master
        build_llvm && setup_for_clang_upstream
        if [ $? -ne 0 ]; then
            echo "Failed to compile clang master"
            exit 1
        fi
    fi
    cd ${ROOT_DIR}
    #https://github.com/96boards/documentation/wiki/HiKeyGettingStarted#section-2 -O hikey-vendor.tar.bz2
    #wget http://builds.96boards.org/snapshots/hikey/linaro/binaries/20150706/vendor.tar.bz2 -O hikey-vendor.tar.bz2
    targets="droid"
#    export TARGET_SYSTEMIMAGES_USE_SQUASHFS=true
#    export TARGET_USERDATAIMAGE_4GB=true
#    export TARGET_USERDATAIMAGE_TYPE=f2fs
    export TARGET_BUILD_KERNEL=true
    export KERNEL_BUILD_WITH_CLANG=true
#    export TARGET_KERNEL_USE_4_1=true
    export TARGET_BOOTIMAGE_USE_FAT=true
    export TARGET_TEE_IS_OPTEE=true
    export TARGET_BUILD_UEFI=true
    export CFG_SECURE_DATA_PATH=y
    export PDK_FUSION_PLATFORM_ZIP=vendor/pdk/mini_arm64/mini_arm64-userdebug/platform/platform.zip

    build hikey
    targets="selinuxtarballs"
}

function build_manta(){
    #export WITH_DEXPREOPT=true
    export TARGET_PREBUILT_KERNEL=device/samsung/manta/kernel
    targets="droidcore"
    build aosp_manta
    unset TARGET_PREBUILT_KERNEL
    targets="selinuxtarballs"
}

function clean_for_manta(){
    rm -fr out/target/product/manta/obj/ETC
    rm -fr out/target/product/manta/boot.img
    rm -fr out/target/product/manta/root
    rm -fr out/target/product/manta/ramdisk*
    rm -fr out/target/product/manta/obj/EXECUTABLES/init_intermediates
}

function build_flounder(){
    export TARGET_PREBUILT_KERNEL=device/htc/flounder-kernel/Image.gz-dtb
    targets="droidcore"
    build aosp_flounder
    unset TARGET_PREBUILT_KERNEL
    targets="selinuxtarballs"
}

function build_flo(){
    export TARGET_PREBUILT_KERNEL=device/asus/flo-kernel/kernel
    targets="droidcore"
    build aosp_flo
    unset TARGET_PREBUILT_KERNEL
    targets="selinuxtarballs"
}

function build_vexpress(){
    export TARGET_UEFI_TOOLS=arm-eabi-
    build vexpress
    unset TARGET_UEFI_TOOLS
}

function build_tools_ddmlib(){
    export JAVA_HOME=/usr/lib/jvm/java-6-openjdk-amd64/
    export PATH=${JAVA_HOME}/bin:$PATH
    export ANDROID_HOME=/backup/soft/adt-bundle-linux/sdk/
    cd tools
    ./gradlew prepareRepo copyGradleProperty
    if [ $? -ne 0 ]; then
        echo "Failed to run:./gradlew prepareRepo copyGradleProperty"
        return
    fi
    ./gradlew assemble
    if [ $? -ne 0 ]; then
        ./gradlew clean assemble
        if [ $? -ne 0 ]; then
            echo "Failed to run:./gradlew clean assemble"
            return
        fi
    fi
    ./gradlew :base:ddmlib:build
    unset JAVA_HOME
}

function build_x15(){

    # compile kernel
    if false; then
        local kernel_dir=${ROOT_DIR}/kernel/ti/x15
        cd ${kernel_dir}
        KERNEL_OUT=${output_dir}/obj/kernel
        rm -fr "${KERNEL_OUT}" && mkdir -p "${KERNEL_OUT}"
        make distclean
        ./ti_config_fragments/defconfig_builder.sh -t ti_sdk_am57x_android_release
        mv -v arch/arm/configs/ti_sdk_am57x_android_release_defconfig ${KERNEL_OUT}/ti_sdk_am57x_android_release_defconfig
        make -j1 O=${KERNEL_OUT} ARCH=arm KCONFIG_ALLCONFIG=${KERNEL_OUT}/ti_sdk_am57x_android_release_defconfig alldefconfig
        if [ $? -ne 0 ]; then
            echo "Failed to generate .config"
            exit
        fi
        make -j${CPUS} O=${KERNEL_OUT} ARCH=arm CROSS_COMPILE="${CROSS_COMPILE}" zImage
        if [ $? -ne 0 ]; then
            echo "Failed to compile kernel"
            exit
        fi

        make O=${KERNEL_OUT} ARCH=arm CROSS_COMPILE="${CROSS_COMPILE}" am57xx-evm-reva3.dtb
        if [ $? -ne 0 ]; then
            echo "Failed to compile dtb"
            exit
        fi
        cd ${ROOT_DIR}/

        cp -fv ${KERNEL_OUT}/arch/arm/boot/zImage device/ti/am57xevm/kernel
    fi

    # compile pvrsrvkm.ko
    if false; then
        local eurasiacon_dir=${ROOT_DIR}/device/ti/proprietary-open/jacinto6/sgx_src/eurasia_km/eurasiacon
        local src_dir=${eurasiacon_dir}/build/linux2/omap_android
        #local pvrsrvkm_f=${eurasiacon_dir}/binary2_omap_android_release/target/pvrsrvkm.ko
        local pvrsrvkm_f=${ROOT_DIR}/out/target/product/am57xevm/target/kbuild/pvrsrvkm.ko

        make V=1 -j${CPUS} \
            ARCH=arm \
            TARGET_DEVICE="am57xevm" \
            TARGET_PRODUCT="am57xevm" \
            BUILD=release \
            KERNELDIR=/SATA3/nougat/out/target/product/am57xevm/obj/kernel/ \
            KERNEL_CROSS_COMPILE=/SATA3/nougat/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8/bin/arm-eabi- \
            CROSS_COMPILE=/SATA3/nougat//prebuilts/gcc/linux-x86/arm/arm-eabi-4.8/bin/arm-eabi- \
            ANDROID_ROOT=/SATA3/nougat \
            OUT=/SATA3/nougat/out/target/product/am57xevm \
            -C ${src_dir}
            build

        mkdir -p ${output_dir}/system/lib/modules
        cp ${pvrsrvkm_f}  ${output_dir}/system/lib/modules
    fi

    # compile android
    export TARGET_BUILD_KERNEL=true
    export TARGET_BUILD_UBOOT=true
    export BOARD_USES_FULL_RECOVERY_IMAGE=true
    export TARGET_USES_MKE2FS=true
    #export TARGET_SYSTEMIMAGES_USE_SQUASHFS=true
    targets="droidcore"
    build full_am57xevm
    targets="selinuxtarballs"

    if false; then
        CROSS_COMPILE="/SATA3/nougat/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-"
        local output_dir=${ROOT_DIR}/out/target/product/am57xevm/obj/u-boot
        local uboot_dir=${ROOT_DIR}/ti/u-boot
        make -C ${uboot_dir} O=${output_dir} ARCH=arm am57xx_evm_nodt_defconfig CROSS_COMPILE="${CROSS_COMPILE}"
        make -C ${uboot_dir} O=${output_dir} -j${CPUS} ARCh=arm CROSS_COMPILE="${CROSS_COMPILE}"
        cp -vf ${output_dir}/u-boot.img ${output_dir}/MLO ${ROOT_DIR}/out/target/product/am57xevm/
    fi
}

clean_build() {
    echo -e "\nINFO: Removing entire out dir. . .\n"
    make clobber
}

build_android() {
    echo -e "\nINFO: Build Android tree for $TARGET\n"
    make $@ | tee $LOG_FILE.log
}

build_bootimg() {
    echo -e "\nINFO: Build bootimage for $TARGET\n"
    make bootimage $@ | tee $LOG_FILE.log
}

build_sysimg() {
    echo -e "\nINFO: Build systemimage for $TARGET\n"
    make systemimage $@ | tee $LOG_FILE.log
}

build_usrimg() {
    echo -e "\nINFO: Build userdataimage for $TARGET\n"
    make userdataimage $@ | tee $LOG_FILE.log
}

build_module() {
    echo -e "\nINFO: Build $MODULE for $TARGET\n"
    make $MODULE $@ | tee $LOG_FILE.log
}

build_project() {
    echo -e "\nINFO: Build $PROJECT for $TARGET\n"
    mmm $PROJECT | tee $LOG_FILE.log
}

#build_vexpress
#build fvp
# clean_for manta && build_manta
#build_tools_ddmlib
#build juno
build_hikey
#build_x15
#build_x20
#build_db410c
#build_flo

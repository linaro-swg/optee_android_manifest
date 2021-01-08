#!/bin/bash

BASE=$(cd $(dirname $0);pwd)

source ${BASE}/scripts-common/sync-common.sh

# overwrite remote MIRROR in sync-common.sh if local mirror exists
if [ -d /opt/aosp/.mirror/platform/manifest.git ]; then
    MIRROR="/opt/aosp/.mirror/platform/manifest.git"
else
    echo "No local mirrors"
fi

##########################################################
##########################################################
while [ "$1" != "" ]; do
	case $1 in
		-zfs) #overwrite zfs_clone in sync-common.sh
			echo "src dir is a zfs clone"
			zfs_clone=true
			;;
		-nl|--nolinaro) # overwrite sync_linaro in sync-common.sh
			echo "Skip local manifests sync"
			sync_linaro=false
			;;
		-bm|--base-manifest) # overwrite base_manifest in sync-common.sh
			shift
			base_manifest=$1
			echo "Use pinned manifest: $1"
			sync_linaro=false
			echo "Force sync_linaro=false"
			;;
		-j)	# set build parallellism
			shift
			echo "Num threads: $1"
			CPUS=$1
			;;
		-v)     # overwrite version in sync-common.sh
			# default is master
			# eg o or p
			shift
			echo "version=$1"
			version=$1
			;;
		-t)     # overwrite board in sync-common.sh
			# default is hikey
			# no other eg atm
			shift
			echo "board=$1"
			board=$1
			;;
		-u)     # overwrite MIRROR in sync-common.sh
			# default remote is https://android.googlesource.com/platform/manifest
			# default local above overwrites default remote
			# specify your own here using -u
			shift
			echo "export MIRROR=$1"
			export MIRROR=$1
			;;
		-d)	# overwrite dbg in helpers
			echo "Print debug"
			dbg=true
			;;
		*)
			echo "Unknown option: $1"
			;;
	esac
	shift
done

# check conflicting args

# no need since we force sync_linaro=false if pinned-manifest specified!
#if $sync_linaro && [[ "${base_manifest}" = "pinned-manifest"* ]]; then
#	echo "Cannot use both local and pinned manifest at the same time!"
#	exit 1
#fi

if [ "${base_manifest}" != "default.xml" ] && [[ "${base_manifest}" != "pinned-manifest"* ]]; then
	echo "Please specify a valid pinned-manifest_YYYYMMDD-HHMM.xml from archive/!"
	exit 1
fi

clean_clear() {
	if [ -d $1 ]; then
		echo "######## CLEAN PATCHED DIRS $1 ########"
		cd $1
		git checkout .
		cd -
	fi
}

clean_clear android-patchsets
clean_clear android-build-configs
clean_clear abc
clean_clear optee/uefi-tools
clean_clear device/linaro/hikey
clean_clear kernel/linaro/hisilicon-4.14

main

#if not stable manifest
if [[ "${base_manifest}" != "pinned-manifest-stable"* ]]; then

if [[ "${base_manifest}" != "pinned-manifest"* ]]; then
${BASE}/sync-projects.sh -j ${CPUS} -d \
                          android-patchsets \
                          android-build-configs \
                          device/linaro/hikey \
                          device/linaro/bootloader/edk2 \
                          frameworks/av \
                          frameworks/base \
                          frameworks/native \
                          system/sepolicy \
                          system/core \
                          system/netd \
                          system/bt \
                          system/libvintf \
                          packages/inputmethods/LatinIME \
                          prebuilts/clang/host/linux-x86 \
                          hardware/interfaces \
                        external/libdrm \
                        frameworks/opt/net/ethernet \
                        system/connectivity/wificond \
                        bootable/recovery \
                        libcore \
                        test/vts \
                        external/optee_test \
                        external/optee_client \
                        external/optee_examples \
                        optee/optee_os \
                        device/linaro/kmgk

if [ "$version" = "master" ] || [ "$version" = "p" ]; then
	echo "unshallow 4.14 kernel"
	${BASE}/sync-projects.sh -j ${CPUS} -d kernel/linaro/hisilicon-4.14
elif [ "$version" = "o" ]; then
	echo "unshallow 4.9 kernel"
	${BASE}/sync-projects.sh -j ${CPUS} -d kernel/linaro/hisilicon
else
	echo "unknown kernel version!"
fi

if [ "$board" = "hikey960" ]; then
	echo "unshallow hikey960 bootloader repos"
	${BASE}/sync-projects.sh -j ${CPUS} -d \
		optee/uefi-tools \
		optee/edk2
fi

fi
#end if not pinned manifest

# apply local patches before
if [ -f "SWG-PATCHSETS-BEFORE" ]; then
	echo "applying patchset: SWG-PATCHSETS-BEFORE"
	func_apply_patch SWG-PATCHSETS-BEFORE
fi

if [ "$dbg" = true ]; then
	echo "CI builds have debugs disabled. Enable them here."
	for i in $(find android-patchsets/ -name swg-mods*); do
		sed -i '/^#apply.* 17632/s/^#//' $i
		sed -i '/^#apply.* 18457/s/^#//' $i
		sed -i '/^#apply.* 18328/s/^#//' $i
	done
fi

git_apply() {
	echo "######## applying $1 to $2 ########"
	cd $1
	git checkout .
	git apply $2
	cd -
}

git_apply android-patchsets ../android-patchsets.patch

# so wif below we'll export different CFG_*
# but it's ok since those CFG_* doesn't affect syncing
# only building
git_apply android-build-configs ../android-build-configs.patch
git_apply abc ../android-build-configs.patch

for i in ${PATCHSETS}; do
	echo ""
	echo ""
	echo "applying patchset: $i"
	func_apply_patch $i
done

git_apply optee/uefi-tools ../../uefi-tools.patch
git_apply device/linaro/hikey ../../../dlh.patch
git_apply kernel/linaro/hisilicon-4.14 ../../../kernel.patch

# apply local patches after
if [ -f "SWG-PATCHSETS-AFTER" ]; then
	echo "applying patchset: SWG-PATCHSETS-AFTER"
	func_apply_patch SWG-PATCHSETS-AFTER
fi

fi
#end if not stable manifest

echo ""
echo ""
echo "Sync done!"
echo "Please make sure there are no errors before building!"

#./build.sh -j ${CPUS} -v ${version} -t {board}
exit

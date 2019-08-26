#!/bin/bash

BASE=$(cd $(dirname $0);pwd)

source ${BASE}/scripts-common/sync-common.sh

unset TGTS

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
		-bm | --base-manifest)
			# overwrite base_manifest in sync-common.sh
			shift
			base_manifest=$1
			echo "Use pinned manifest: $1"
			sync_linaro=false
			echo "Force sync_linaro=false"
			;;
		-d)	# overwrite dbg in helpers
			echo "Print debug"
			dbg=true
			;;
		-ip | --install-packages)
			# overwrite install_pkg in sync-common.sh
			echo "Install deps"
			install_pkg=true
			;;
		-j)	# set build parallellism
			# overwrite CPUS in helpers
			shift
			echo "Num threads: $1"
			CPUS=$1
			;;
		-nl | --nolinaro)
			# overwrite sync_linaro in sync-common.sh
			echo "Skip local manifests sync"
			sync_linaro=false
			;;
		--ref)	# sync referencing an existing source tree (forest)
			# overwrite REF in sync-common.sh
			shift
			echo "set --reference $1"
			REF=$1
			;;
		-s | -sync-target)
			echo "Adding sync target: $1"
			TGTS=(${TGTS[@]} $1)
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
		-v)     # overwrite version in sync-common.sh
			# default is master
			# eg o or p
			shift
			echo "version=$1"
			version=$1
			;;
		-wv)	#overwrite wv in helpers
			echo "wv build"
			wv=true
			;;
		-zfs)	#overwrite zfs_clone in sync-common.sh
			echo "src dir is a zfs clone"
			zfs_clone=true
			;;
		*)	# default adds to target list without shift
			echo "Adding sync target by default: $1"
			TGTS=(${TGTS[@]} $1)
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

if [ X"$TGTS" != X"" ]; then
	echo "sync targets: ${TGTS[@]}"
fi

main

if [ X"$TGTS" != X"" ]; then
	exit
fi

#if not stable manifest
if [[ "${base_manifest}" != "pinned-manifest-stable"* ]]; then

if [[ "${base_manifest}" != "pinned-manifest"* ]]; then
${BASE}/sync-projects.sh -j ${CPUS} -d \
                          android-patchsets \
                          android-build-configs \
                          build/make \
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

if [ "$wv" = true ]; then
	echo "unshallow wv repos"
	${BASE}/sync-projects.sh -j ${CPUS} -d \
		external/optee-widevine-ref \
		vendor/widevine
		#vendor/widevine \
		#ExoPlayer
fi

fi
#end if not pinned manifest

# apply local patches before
if [ -f "SWG-PATCHSETS-BEFORE" ]; then
	echo "applying patchset: SWG-PATCHSETS-BEFORE"
	func_apply_patch SWG-PATCHSETS-BEFORE
fi

if [ "$dbg" = true ]; then
	echo ""
	echo "CI builds have debugs disabled. Enable them here."
	for i in $(find android-patchsets/ -name swg-mods*); do
		sed -i '/^#apply.* 17632/s/^#//' $i
		sed -i '/^#apply.* 18328/s/^#//' $i
		sed -i '/^#apply.* 18457/s/^#//' $i
		sed -i '/^#apply.* 20096/s/^#//' $i
		sed -i '/^#curl_am_optee.* cf7c607f/s/^#//' $i
	done
fi

for i in ${PATCHSETS}; do
	echo ""
	echo ""
	echo "applying patchset: $i"
	func_apply_patch $i
done

# apply local patches after
if [ -f "SWG-PATCHSETS-AFTER" ]; then
	echo "applying patchset: SWG-PATCHSETS-AFTER"
	func_apply_patch SWG-PATCHSETS-AFTER
fi

fi
#end if not stable manifest

if [ "$install_pkg" = true ]; then
	echo ""
	echo ""
	echo "Installing dep pkgs before build"
	install_packages
fi

echo ""
echo ""
echo "Sync done!"
echo "Please make sure there are no errors before building!"

#./build.sh -j ${CPUS} -v ${version} -t {board}
exit

#!/bin/bash

BASE=`pwd`

source ${BASE}/scripts-common/helpers

MIRROR="https://android.googlesource.com/platform/manifest"

repo_url="git://android.git.linaro.org/tools/repo"
base_manifest="default.xml"
sync_linaro=true
zfs_clone=false

version="master"
board="hikey"

sync_init(){
    if [[ "${base_manifest}" = "pinned-manifest"* ]]; then
        echo "using pinned manifest - init with full depth"
        echo "repo init -u ${MIRROR} -b ${MANIFEST_BRANCH} --no-repo-verify --repo-url=${repo_url} -g ${REPO_GROUPS} -p linux"
        repo init -u ${MIRROR} -b ${MANIFEST_BRANCH} --no-repo-verify --repo-url=${repo_url} -g ${REPO_GROUPS} -p linux
    else
        echo "not using pinned manifest - init with depth 1"
        echo "repo init -u ${MIRROR} -b ${MANIFEST_BRANCH} --no-repo-verify --repo-url=${repo_url} --depth=1 -g ${REPO_GROUPS} -p linux"
        repo init -u ${MIRROR} -b ${MANIFEST_BRANCH} --no-repo-verify --repo-url=${repo_url} --depth=1 -g ${REPO_GROUPS} -p linux
    fi
}

clean_changes(){
    echo "hack: clean $1 of build changes before sync"
    if [ -d $1 ]; then
        pushd $1
        if git status | grep -q $2; then
                git checkout .
        fi
        popd
    fi
}

sync(){
    clean_changes device/linaro/hikey fip.bin
    clean_changes android-patchsets swg-mods-${version}

    if [ "${base_manifest}" = "default.xml" ]; then
	echo "repo sync -j${CPUS} -c --force-sync"
	repo sync -j${CPUS} -c --force-sync

	echo "Save revisions to pinned manifest"
	mkdir -p archive
	repo manifest -r -o archive/pinned-manifest_${board}_${version}_"$(date +%Y%m%d-%H%M)".xml
    else
	echo "repo sync -j${CPUS} -m ${base_manifest}"
	repo sync -j${CPUS} -m ${base_manifest}
    fi
}

func_cp_manifest(){
    echo "rm local_manifests and cp pinned manifests to .repo/manifests/"
    rm -rf .repo/local_manifests
    cp archive/${base_manifest} .repo/manifests/
}

func_sync_linaro(){
    pushd .repo
    echo "rm pinned manifest"
    rm -f manifests/pinned-manifest*.xml
    if [ -d ./local_manifests ]; then
        cd ./local_manifests;
	echo "git pull local manifest"
        git pull origin ${LOCAL_MANIFEST_BRANCH}
    else
	echo "git clone ${LOCAL_MANIFEST} -b ${LOCAL_MANIFEST_BRANCH} local_manifest"
        git clone ${LOCAL_MANIFEST} -b ${LOCAL_MANIFEST_BRANCH} local_manifests
    fi
    popd

#    if [ "$board" = "hikey" ]; then
#	cp -auvf swg-${version}.xml .repo/local_manifests/
#    else
#	cp -auvf swg-${version}-${board}.xml .repo/local_manifests/
#    fi
}

hikey_mali_binary_old(){
    local b_name="hikey-20160113-vendor.tar.bz2"
    if [ -f ./${b_name} ]; then
        return
    fi
    curl --fail --show-error -b license_accepted_eee6ac0e05136eb58db516d8c9c80d6b=yes http://snapshots.linaro.org/android/binaries/hikey/20160113/vendor.tar.bz2 >${b_name}
    tar xavf ${b_name}
}

hikey_mali_binary(){
	wget --no-check-certificate https://dl.google.com/dl/android/aosp/linaro-hikey-20170523-4b9ebaff.tgz
	for i in linaro-hikey-*.tgz; do
		tar xf $i
	done
	mkdir junk
	echo 'cat "$@"' >junk/more
	chmod +x junk/more
	export PATH=`pwd`/junk:$PATH
	for i in extract-linaro-hikey.sh; do
		echo -e "\nI ACCEPT" |./$i
	done
	rm -rf junk linaro-hikey-*.tgz extract-linaro-hikey.sh
}

hikey960_mali_binary(){
	wget --no-check-certificate https://dl.google.com/dl/android/aosp/hisilicon-hikey960-OPR-3c243263.tgz
	for i in hisilicon-hikey960-*.tgz; do
		tar xf $i
	done
	mkdir junk
	echo 'cat "$@"' >junk/more
	chmod +x junk/more
	export PATH=`pwd`/junk:$PATH
	for i in extract-hisilicon-hikey960.sh; do
		echo -e "\nI ACCEPT" |./$i
	done
	rm -rf junk hisilicon-hikey960-*.tgz extract-hisilicon-hikey960.sh
}

main(){
    mkdir -p logs

    # update myself first
    git pull
    get_config
    export_config

    # if MIRROR is local then repo sync
    if [[ "X${MIRROR}" = X/* ]]; then
        mirror_dir=$(dirname $(dirname ${MIRROR}))
        echo "Skip repo sync local mirror for now!"
        #repo sync -j${CPUS} "${mirror_dir}"
    fi

    # init repos
    sync_init

    if $sync_linaro; then
	echo "Sync local manifest"
	func_sync_linaro
    else
	if [ "${base_manifest}" = "default.xml" ]; then
		echo "Skip local manifest sync"
	elif [[ "${base_manifest}" = "pinned-manifest"* ]]; then
		func_cp_manifest
	else # should NEVER be here with args check in sync.sh
		echo "Unknown manifest!"
	fi
    fi

    # sync repos
    sync

    # cp local patch file if exist
    if [ ! -d android-patchsets ]; then
        mkdir -p android-patchsets
    fi
    if [ -f "SWG-PATCHSETS-BEFORE" ] || [ -f "SWG-PATCHSETS-AFTER" ]; then
        echo "cp SWG-PATCHSETS-* to android-patchsets/"
        rm -f android-patchsets/SWG-PATCHSETS-*
        cp -auvf SWG-PATCHSETS-* android-patchsets/
    fi
    #${board}_mali_binary
}

function func_apply_patch(){
    local patch_name=$1
    if [ -z "${patch_name}" ]; then
        return
    fi

    if [[ "${patch_name}" = "optee"* ]] && [[ $1 =~ [0-9]+ ]]; then
	echo "Skip ${patch_name} since we're using master!"
	return
    fi

    if [ ! -f "./android-patchsets/${patch_name}" ]; then
	echo "android-patchsets/${patch_name}: no such file!"
        return
    fi

    ./android-patchsets/${patch_name}
    if [ $? -ne 0 ]; then
        echo "Failed to run ${patch_name}"
        exit 1
    fi
}

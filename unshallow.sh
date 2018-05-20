#!/bin/bash

ROOT=${ROOT:-$(pwd)}
echo "ROOT = ${ROOT}"

echo "unshallow frameworks/base for hikey-o-workarounds"
cd ${ROOT}/frameworks/base
git fetch aosp --unshallow

echo "unshallow packages/inputmethods/LatinIME for O-RLCR-PATCHSET"
cd ${ROOT}/packages/inputmethods/LatinIME
git fetch aosp --unshallow

echo "unshallow system/netd for O-RLCR-PATCHSET"
cd ${ROOT}/system/netd
git fetch aosp --unshallow

echo "unshallow system/core for O-RLCR-PATCHSET"
cd ${ROOT}/system/core
git fetch aosp --unshallow

echo "unshallow system/sepolicy for O-RLCR-PATCHSET"
cd ${ROOT}/system/sepolicy
git fetch aosp --unshallow

echo "unshallow frameworks/native for O-RLCR-PATCHSET"
cd ${ROOT}/frameworks/native
git fetch aosp --unshallow

echo "unshallow system/connectivity/wificond O-RLCR-PATCHSET"
cd ${ROOT}/system/connectivity/wificond
git fetch aosp --unshallow

echo "unshallow bootable/recovery O-RLCR-PATCHSET"
cd ${ROOT}/bootable/recovery
git fetch aosp --unshallow

echo "unshallow external/libdrm O-RLCR-PATCHSET"
cd ${ROOT}/external/libdrm
git fetch aosp --unshallow

echo "unshallow libcore for O-RLCR-PATCHSET"
cd ${ROOT}/libcore
git fetch aosp --unshallow

echo "unshallow frameworks/opt/net/ethernet for OREO-BOOTTIME-OPTIMIZATIONS-HIKEY"
cd ${ROOT}/frameworks/opt/net/ethernet
git fetch aosp --unshallow

echo "unshallow android-patchsets"
cd ${ROOT}/android-patchsets
git fetch linaro-android --unshallow

echo "unshallow dlh"
cd ${ROOT}/device/linaro/hikey
git fetch aosp --unshallow

echo "unshallow kernel"
cd ${ROOT}/kernel/linaro/hisilicon
git fetch aosp --unshallow

echo "unshallow xtest"
cd ${ROOT}/external/optee_test
git fetch github --unshallow

echo "unshallow client"
cd ${ROOT}/external/optee_client
git fetch github --unshallow

echo "unshallow optee_examples"
cd ${ROOT}/external/optee_examples
git fetch github-optee --unshallow

echo "unshallow optee_os"
cd ${ROOT}/optee/optee_os
git fetch github --unshallow

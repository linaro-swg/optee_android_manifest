#!/bin/bash

ROOT=${ROOT:-$(pwd)}
echo "ROOT = ${ROOT}"

echo "unshallow frameworks/base for hikey-n-workarounds"
cd ${ROOT}/frameworks/base
git fetch aosp --unshallow

echo "unshallow external/libcxx for NOUGAT-RLCR-PATCHSET"
cd ${ROOT}/external/libcxx
git fetch aosp --unshallow

echo "unshallow external/mksh for NOUGAT-RLCR-PATCHSET"
cd ${ROOT}/external/mksh
git fetch aosp --unshallow

echo "unshallow external/libjpeg-turbo for NOUGAT-RLCR-PATCHSET"
cd ${ROOT}/external/libjpeg-turbo
git fetch aosp --unshallow

echo "unshallow system/core for NOUGAT-RLCR-PATCHSET"
cd ${ROOT}/system/core
git fetch aosp --unshallow

echo "unshallow system/netd for NOUGAT-RLCR-PATCHSET"
cd ${ROOT}/system/netd
git fetch aosp --unshallow

echo "unshallow android-patchsets"
cd ${ROOT}/android-patchsets
git fetch linaro-android --unshallow

echo "unshallow dlh"
cd ${ROOT}/device/linaro/hikey
git fetch linaro-android --unshallow

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
git fetch github --unshallow

echo "unshallow optee_os"
cd ${ROOT}/optee/optee_os
git fetch github --unshallow

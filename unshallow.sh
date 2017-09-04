#!/bin/bash

ROOT=${ROOT:-$(pwd)}
echo "ROOT = ${ROOT}"

echo "unshallow frameworks/base for hikey-n-workarounds"
cd ${ROOT}/frameworks/base
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

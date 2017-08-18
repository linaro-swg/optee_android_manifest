#!/bin/bash

echo "unshallow frameworks/base for hikey-n-workarounds"
cd ~/work/swg/svp/hikey-n-4.9/frameworks/base
git fetch aosp --unshallow
cd ~/work/swg/svp/hikey-n-4.9/android-patchsets
git fetch linaro-android --unshallow
echo "unshallow dlh"
cd ~/work/swg/svp/hikey-n-4.9/device/linaro/hikey
git fetch linaro-android --unshallow
echo "unshallow kernel"
cd ~/work/swg/svp/hikey-n-4.9/kernel/linaro/hisilicon
git fetch aosp --unshallow
echo "unshallow xtest"
cd ~/work/swg/svp/hikey-n-4.9/external/optee_test
git fetch github --unshallow
echo "unshallow client"
cd ~/work/swg/svp/hikey-n-4.9/external/optee_client
git fetch github --unshallow
echo "unshallow hello world"
cd ~/work/swg/svp/hikey-n-4.9/external/optee_hello_world
git fetch github --unshallow
echo "unshallow optee_os"
cd ~/work/swg/svp/hikey-n-4.9/optee/optee_os
git fetch github --unshallow

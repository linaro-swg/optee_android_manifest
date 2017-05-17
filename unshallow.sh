#!/bin/bash

cd ~/work/swg/svp/hikey-n-4.9/android-patchsets
git fetch linaro-android --unshallow
cd ~/work/swg/svp/hikey-n-4.9/device/linaro/hikey
git fetch linaro-android --unshallow
cd ~/work/swg/svp/hikey-n-4.9/kernel/linaro/hisilicon
git fetch aosp --unshallow
cd ~/work/swg/svp/hikey-n-4.9/external/optee_test
git fetch github --unshallow
cd ~/work/swg/svp/hikey-n-4.9/external/optee_client
git fetch github --unshallow
cd ~/work/swg/svp/hikey-n-4.9/external/optee_hello_world
git fetch github --unshallow
cd ~/work/swg/svp/hikey-n-4.9/optee/optee_os
git fetch github --unshallow

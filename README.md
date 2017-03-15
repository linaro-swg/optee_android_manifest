# Android+OP-TEE manifest

This repository contains a local manifest that can be used to build an
AOSP build that includes OP-TEE for the hikey board.

## 1. References

* [AOSP Hikey build instructions][1]

## 2. Prerequisites

* Should already be able to build aosp.  Distro should have necessary
  packages installed, and the repo tool should be installed.  Note
  that AOSP needs to be built with Java.  Also make sure that
  the `mtools` package is installed, which is needed to make the hikey
  boot image.

* In addition, you will need the pre-requisites necessary to build
  optee-os.

  After following the AOSP setup instructions, the following
  additional packages are needed.

```bash
$ sudo apt-get install bc ncurses-dev realpath python-crypto \
     android-tools-fsutils dosfstools python-wand
```

## 3. Build steps

### 3.1. In an empty directory, clone the tree:
```bash
$ repo init -u https://android-git.linaro.org/git/platform/manifest.git -b android-7.1.1_r22 -g "default,-non-default,-device,hikey,fugu"
# repo init -u /home/ubuntu/aosp-mirror/platform/manifest.git -b android-7.1.1_r22 -g "default,-non-default,-device,hikey,fugu" -p linux --depth=1
```
**WARNING**: Do NOT use --depth=1 option!
### 3.2. Add the OP-TEE overlay:
```bash
$ cd .repo
$ git clone https://github.com/linaro-swg/optee_android_manifest.git -b hikey-n-4.9 local_manifests
$ cd ..
```
### 3.3. Sync
```bash
$ repo sync -j12
```
**WARNING**: Do NOT use -c option!
### 3.4. Apply the required patches
``` bash
$ ./android-patchsets/hikey-n-workarounds
$ ./android-patchsets/hikey-optee-4.9
$ ./android-patchsets/hikey-optee-n
$ ./android-patchsets/optee-230-workarounds
```
### 3.5. Download the HiKey vendor binary
```bash
$ wget https://dl.google.com/dl/android/aosp/linaro-hikey-20160226-67c37b1a.tgz
$ tar xzf linaro-hikey-20160226-67c37b1a.tgz
$ ./extract-linaro-hikey.sh
```
### 3.6. Configure the environment for Android
```bash
source ./build/envsetup.sh
lunch hikey-userdebug
```
### 3.7. Build the booloader firmware (fip.bin)
```bash
$ pushd device/linaro/hikey/bootloader
$ make TARGET_TEE_IS_OPTEE=true #make sure build is successful
$ popd
$ cp out/dist/fip.bin device/linaro/hikey/installer/hikey/
```

### 3.8. Run the rest of the android build, For an 8GB board, use:
```bash
make -j12 TARGET_BUILD_KERNEL=true #TARGET_BOOTIMAGE_USE_FAT=true
```
For a 4GB board, use:
```bash
make -j12 TARGET_USERDATAIMAGE_4GB=true TARGET_BUILD_KERNEL=true #TARGET_BOOTIMAGE_USE_FAT=true
```

## 4. Flashing the image
The instructions for flashing the image can be found in detail under
`device/linaro/hikey/install/README` in the tree.
1. Jumper links 1-2 and 3-4, leaving 5-6 open, and reset the board.
2. Invoke
```bash
./device/linaro/hikey/installer/flash-all.sh /dev/ttyUSBn
```
where the ttyUSBn device is the one that appears after rebooting with
the 3-4 jumper installed.  Note that the device only remains in this
recovery mode for about 90 seconds.  If you take too long to run the
flash commands, it will need to be reset again.

## 5. Partial flashing
The last handful of lines in the `flash-all.sh` script flash various
images.  After modifying and rebuilding Android, it is only necessary
to flash *boot*, *system*, *cache*, and *userdata*.  If you aren't
modifying the kernel, *boot* is not necessary, either.

[1]: https://source.android.com/source/devices.html

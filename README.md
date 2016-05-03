# Android+OP-TEE manifest

This repository contains a local manifest that can be used to build an
AOSP build that includes OP-TEE for the hikey board.

## 1. References

* [AOSP Hikey build instructions][1]

## 2. Prerequisites

* Should already be able to build aosp.  Distro should have necessary
  packages installed, and the repo tool should be installed.  Note
  that AOSP 6 needs to be built with Java 1.8.  Also make sure that
  the `mtools` package is installed, which is needed to make the hikey
  boot image.

## 3. Build steps

### 3.1. In an empty directory, clone the tree:
```bash
$ repo init -u https://android.googlesource.com/platform/manifest -b master
```
### 3.2. Add the OP-TEE overlay:
```bash
$ cd .repo
$ git clone https://github.com/linaro-swg/optee_android_manifest.git local_manifests
$ cd ..
```
### 3.3. Sync
```bash
$ repo sync
```
### 3.4. Download the HiKey vendor binary
```bash
$ wget https://dl.google.com/dl/android/aosp/linaro-hikey-20160226-67c37b1a.tgz
$ tar xzf linaro-hikey-20160226-67c37b1a.tgz
$ ./extract-linaro-hikey.sh
```
### 3.5. Configure the environment for Android
```bash
source ./build/envsetup.sh
lunch hikey-userdebug
```

### 3.6. Download the Linaro toolchain
The Linux kernel and Optee trusted apps are built using the Linaro gcc
toolchain.  Use this helper script to download this for you:
```bash
$ ./optee/get_toolchain.sh
```

### 3.7. Build the userspace libraries and trusted apps:
```bash
$ ./optee/build_ta.sh hikey optee/android_optee_examples.cfg
```

### 3.8. Build the Linux kernel
There is also a helper script to build the Linux kernel.  Android
typically uses pre-built kernels, so it is necessary to build this
manually.
```bash
$ ./optee/build_kernel.sh
```

### 3.9. Run the rest of the android build, For an 8GB board, use:
```bash
make -j32
```
For a 4GB board, use:
```bash
make -j32 TARGET_USERDATAIMAGE_4GB=true
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

This directory contains a prebuilt trusted firmware image `fip.bin`.
If you wish to build the trusted os from source, follow the HiKey
instructions in the [OP-TEE OS README][2].  After running the build,
the `fip.bin` file will be under
```
arm-trusted-firmware/build/hikey/release/fip.bin
```

[1]: https://source.android.com/source/devices.html
[2]: https://github.com/OP-TEE/optee_os/blob/master/README.md

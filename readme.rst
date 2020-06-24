####################
AOSP+OP-TEE manifest
####################

Build Guide
-----------

::

    git clone https://github.com/linaro-swg/optee_android_manifest -b master-dirty
    cd optee_android_manifest
    ./sync-master-hikey960.sh
    ./build-master-hikey960.sh

Prebuilt `download`_.

Ignore Below
------------

This repository contains scripts that can be used to build an AOSP build that
includes OP-TEE for the HiKey boards. The build is based on the latest OP-TEE
release and updated every quarter.

All official OP-TEE documentation has moved to http://optee.readthedocs.io. The
information that used to be here in this git can be found under `AOSP`_.

// OP-TEE core maintainers

.. _download: https://people.linaro.org/~victor.chong/prebuilt/master/390-dirty/hikey960/
.. _AOSP: https://optee.readthedocs.io/building/aosp/aosp.html

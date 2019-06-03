#!/bin/bash

./build.sh -wv -t hikey960_tv "$@" 2>&1 |tee logs/build-master.log

#!/bin/bash

./build.sh -t hikey960 "$@" 2>&1 |tee logs/build-master.log

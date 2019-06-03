#!/bin/bash

./build.sh "$@" 2>&1 |tee logs/build-master.log

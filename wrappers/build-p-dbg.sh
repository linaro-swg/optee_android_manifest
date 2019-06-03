#!/bin/bash

./build.sh -v p -d "$@" 2>&1 |tee logs/build-p.log

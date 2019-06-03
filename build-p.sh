#!/bin/bash

./build.sh -v p "$@" 2>&1 |tee logs/build-p.log

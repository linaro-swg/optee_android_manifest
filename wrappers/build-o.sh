#!/bin/bash

./build.sh -v o "$@" 2>&1 |tee logs/build-o.log

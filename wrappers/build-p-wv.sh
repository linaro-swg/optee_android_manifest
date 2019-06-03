#!/bin/bash

./build.sh -v p -wv "$@" 2>&1 |tee logs/build-p.log

#!/bin/bash

./build.sh -v p -wv -t hikey960 "$@" 2>&1 |tee logs/build-p.log

#!/bin/bash

./sync.sh -v p -wv -t hikey960 "$@" 2>&1 |tee logs/sync-p.log

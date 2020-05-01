#!/bin/bash

./sync.sh -v p -d -t hikey960 -bm pinned-manifest_hikey960_v9r34_v3.8.2_20200501.xml "$@" 2>&1 |tee logs/sync-p.log
#./sync.sh -v p -t hikey960 "$@" 2>&1 |tee logs/sync-p.log

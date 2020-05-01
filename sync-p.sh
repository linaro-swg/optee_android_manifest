#!/bin/bash

./sync.sh -v p -d -bm pinned-manifest_hikey_v9r34_v3.8.2_20200501.xml "$@" 2>&1 |tee logs/sync-p.log
#./sync.sh -v p "$@" 2>&1 |tee logs/sync-p.log

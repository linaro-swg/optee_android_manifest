#!/bin/bash

./sync.sh -v p -d 2>&1 |tee logs/sync-p.log
#./sync.sh -v p -bm pinned-manifest_YYYYMMDD-HHMM -d 2>&1 |tee logs/sync-p.log
#./sync.sh -v p -j 24 -d 2>&1 |tee logs/sync-p.log

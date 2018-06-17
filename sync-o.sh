#!/bin/bash

./sync.sh -v o -d 2>&1 |tee logs/sync-o.log
#./sync.sh -v o -bm pinned-manifest_YYYYMMDD-HHMM -d 2>&1 |tee logs/sync-o.log
#./sync.sh -v o -j24 -d 2>&1 |tee logs/sync-o.log

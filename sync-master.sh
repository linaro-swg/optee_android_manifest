#!/bin/bash

mkdir -p logs
./sync.sh -d 2>&1 |tee logs/sync-master.log
#./sync.sh -bm pinned-manifest_YYYYMMDD-HHMM -d 2>&1 |tee logs/sync-master.log
#./sync.sh -j 24 -d 2>&1 |tee logs/sync-master.log

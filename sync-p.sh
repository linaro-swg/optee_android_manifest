#!/bin/bash

mkdir -p logs
./sync.sh -v p -bm pinned-manifest_hikey_v9r30_v3.4.0_20190128.xml 2>&1 |tee logs/sync-p.log
#./sync.sh -v p 2>&1 |tee logs/sync-p.log

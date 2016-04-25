#!/bin/bash

./sync.sh -v p -t hikey960 -bm pinned-manifest_hikey960_v9r30_v3.4.0_20190128.xml 2>&1 |tee logs/sync-p.log
#./sync.sh -v p -t hikey960 2>&1 |tee logs/sync-p.log

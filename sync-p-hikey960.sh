#!/bin/bash

./sync.sh -v p -t hikey960 -bm pinned-manifest_hikey960_v9r30_v3.13.0_20210421.xml 2>&1 |tee logs/sync-p.log
#./sync.sh -v p -t hikey960 2>&1 |tee logs/sync-p.log
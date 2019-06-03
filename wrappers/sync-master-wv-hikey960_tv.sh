#!/bin/bash

./sync.sh -wv -t hikey960_tv "$@" 2>&1 |tee logs/sync-master.log

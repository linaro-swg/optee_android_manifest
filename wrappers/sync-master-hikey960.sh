#!/bin/bash

./sync.sh -t hikey960 "$@" 2>&1 |tee logs/sync-master.log

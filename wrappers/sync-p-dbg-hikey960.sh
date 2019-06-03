#!/bin/bash

./sync.sh -v p -d -t hikey960 "$@" 2>&1 |tee logs/sync-p.log

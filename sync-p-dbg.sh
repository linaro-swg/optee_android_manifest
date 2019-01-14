#!/bin/bash

mkdir -p logs
./sync.sh -v p -d 2>&1 |tee logs/sync-p.log

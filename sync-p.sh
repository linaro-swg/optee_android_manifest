#!/bin/bash

mkdir -p logs
./sync.sh -v p 2>&1 |tee logs/sync-p.log

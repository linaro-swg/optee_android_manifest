#!/bin/bash

mkdir -p logs
./sync.sh 2>&1 |tee logs/sync-master.log

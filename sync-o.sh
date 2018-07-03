#!/bin/bash

mkdir -p logs
./sync.sh -v o 2>&1 |tee logs/sync-o.log

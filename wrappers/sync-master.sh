#!/bin/bash

./sync.sh "$@" 2>&1 |tee logs/sync-master.log

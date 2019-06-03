#!/bin/bash

./sync.sh -v p "$@" 2>&1 |tee logs/sync-p.log

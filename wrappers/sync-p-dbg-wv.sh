#!/bin/bash

./sync.sh -v p -d -wv "$@" 2>&1 |tee logs/sync-p.log

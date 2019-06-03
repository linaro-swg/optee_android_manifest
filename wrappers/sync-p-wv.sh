#!/bin/bash

./sync.sh -v p -wv "$@" 2>&1 |tee logs/sync-p.log

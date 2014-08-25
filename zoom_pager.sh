#!/usr/bin/env bash

CACHE_FILE=~/.zoom_cache

echo "ZOOM_EXE_DIR=$(pwd)" > $CACHE_FILE
while read line; do
    echo "$line"
done < "${1:-/dev/stdin}" >> $CACHE_FILE

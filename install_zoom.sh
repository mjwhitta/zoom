#!/usr/bin/env bash

usage() {
    echo "Usage: ${0/*\//} [install_dir]"
    echo "Options:"
    echo "    -h"
    echo "        Display this help message"
    echo
    exit $1
}

if [ $# -gt 1 ]; then
    usage 1
fi

INSTALL_DIR="$HOME/bin"
case "$1" in
    "-h"|"--help") usage 0
        ;;
    *)
        if [ "$1" ]; then
            INSTALL_DIR="$1"
        fi
        ;;
esac

echo -n "Installing zoom..."

# Save install location
cwd=$(pwd)

# Make sure ~/bin exists and go to it
mkdir -p $INSTALL_DIR && cd $INSTALL_DIR

# Copy
cp $cwd/zoom.rb z
[ ! -e zc ] && ln -fs z zc
[ ! -e zf ] && ln -fs z zf
[ ! -e zg ] && ln -fs z zg
[ ! -e zl ] && ln -fs z zl
[ ! -e zr ] && ln -fs z zr

# Create zoomrc if needed
if [ ! -e ~/.zoomrc ]; then
    ./z --rc
fi

echo "done!"

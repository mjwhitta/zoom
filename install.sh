#!/usr/bin/env bash

usage() {
    echo "Usage: ${0/*\//} [install_dir] [name]"
    echo "Options:"
    echo "    -h"
    echo "        Display this help message"
    echo
    exit $1
}

[ $# -gt 2 ] && usage 1

INSTALL_DIR="$HOME/bin"
case "$1" in
    "-h"|"--help") usage 0
        ;;
    *) [ "$1" ] && INSTALL_DIR="$1"
        ;;
esac

NAME="z"
[ $# -eq 2 ] && NAME="$2"

echo -n "Installing zoom..."

# Save install location
cwd=$(pwd)

# Make sure ~/bin exists and go to it
mkdir -p $INSTALL_DIR && cd $INSTALL_DIR

# Copy
cp $cwd/zoom.rb $NAME
[ -e zc ] || ln -fs  $NAME zc
[ -e zf ] || ln -fs  $NAME zf
[ -e zg ] || ln -fs  $NAME zg
[ -e zl ] || ln -fs  $NAME zl
[ -e zr ] || ln -fs  $NAME zr

echo "done!"

#!/usr/bin/env bash

echo -n "Installing zoom..."

# Save install location
install_dir=$(pwd)

# Make sure ~/bin exists and go to it
mkdir -p ~/bin && cd ~/bin

# Copy
cp $install_dir/zoom.rb z
[ ! -e zc ] && ln -fs z zc
[ ! -e zg ] && ln -fs z zg
[ ! -e zl ] && ln -fs z zl
cp $install_dir/zoom_pager.sh .
chmod u+x z zoom_pager.sh

# Create zoomrc if needed
if [ ! -e ~/.zoomrc ]; then
    ./z --rc
fi

echo "done!"

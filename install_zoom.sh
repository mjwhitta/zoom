#!/usr/bin/env bash

echo -n "Installing zoom..."

# Save install location
install_dir=$(pwd)

# Make sure ~/bin exists and go to it
mkdir -p ~/bin && cd ~/bin

# Copy
cp $install_dir/zoom.rb z
ln -fs z zc
ln -fs z zg
ln -fs z zl
cp $install_dir/zoom_pager.sh .

# Create zoomrc if needed
if [ ! -e .zoomrc ]; then
    $install_dir/zoom.rb --rc
fi

echo "done!"

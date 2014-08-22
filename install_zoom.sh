#!/usr/bin/env bash

# Save install location
install_dir=$(pwd)

# Make sure ~/bin exists and go to it
mkdir -p ~/bin
cd ~/bin

# Copy
echo -n "Installing zoom..."
cp $install_dir/zoom.rb z
cp $install_dir/zoom_pager.sh .

# Move to home dir and create zoomrc if needed
cd
if [ ! -e .zoomrc ]; then
    $install_dir/zoom.rb --rc
fi
echo "done!"

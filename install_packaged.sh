#!/bin/bash

# Install Font
mkdir -p ~/.local/share/fonts
unzip ./fd-v10.2.0-x86_64-unknown-linux-gnu.tar.gz -d ~/.local/share/fonts
fc-cache -f -v

chmod u+x ./nvim.appimage

mkdir -p ~/.local/bin/

cp ./nvim.appimage ~/.local/bin/
cp -r ./nvim.appimage.home ~/.local/bin/


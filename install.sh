#!/bin/bash

mkdir GrassNvim
cd GrassNvim

# Install Neovim 0.10.0+
wget2 https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x ./nvim.appimage

mkdir nvim.appimage.home
mkdir -p nvim.appimage.home/.local/share/nvim
mkdir -p nvim.appimage.home/.local/bin
mkdir -p nvim.appimage.home/.config/nvim

cp ../* ./GrassNvim

# Install fd-find
wget2 https://github.com/sharkdp/fd/releases/download/v10.2.0/fd-v10.2.0-x86_64-unknown-linux-gnu.tar.gz
tar -xvzf ./fd-v10.2.0-x86_64-unknown-linux-gnu.tar.gz -c ./nvim.appimage.home/.local/bin

# Install ripgrep
wget2 https://github.com/BurntSushi/ripgrep/releases/download/14.1.1/ripgrep-14.1.1-aarch64-unknown-linux-gnu.tar.gz
tar -xvzf ./fd-v10.2.0-x86_64-unknown-linux-gnu.tar.gz -c ./nvim.appimage.home/.local/bin

# Install Nerd-Font
wget2 https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip
mkdir -p ~/.local/share/fonts
unzip ./fd-v10.2.0-x86_64-unknown-linux-gnu.tar.gz -d ~/.local/share/fonts
fc-cache -f -v

# Start nvim and execute Lazy.nvim install
nvim --headless "+Lazy! sync" +qa

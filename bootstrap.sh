#! /usr/bin/env bash

set -eu

git clone https://github.com/jruhland/dotfiles.git ~/.dotfiles

cd ~/.dotfiles

# Install homebrew
which brew || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install homebrew packages
brew bundle install

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

mkdir -p ~/.config

# symlink our dotfiles
ln -s `pwd`/.zshrc ~/.zshrc
ln -s `pwd`/.gitconfig ~/.gitconfig
ln -s `pwd`/.gitignore_global ~/.gitignore
ln -s `pwd`/.config/gh ~/.config/gh
ln -s `pwd`/.config/nvim ~/.config/nvim
ln -s `pwd`/.ghostty ~/.ghostty
ln -s `pwd`/aliases.zsh $ZSH_CUSTOM/aliases.zsh

# load our versions
mise trust
mise install

npm install -g @anthropic-ai/claude-code

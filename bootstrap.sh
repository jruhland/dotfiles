#! /usr/bin/env bash

set -eu

git clone https://github.com/jruhland/dotfiles.git ~/.dotfiles

cd ~/.dotfiles

# Install homebrew
which brew || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install homebrew packages
brew bundle install

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

dotter deploy -v

# install all our preferred versions
asdf install

npm install -g @anthropic-ai/claude-code

#!/usr/bin/env bash

set -eu

OS="$(uname -s)"
is_darwin() { [ "$OS" = "Darwin" ]; }
is_linux() { [ "$OS" = "Linux" ]; }

echo "Bootstrapping dotfiles for $OS..."

# Install Xcode Command Line Tools (macOS only)
if is_darwin; then
  if ! xcode-select -p &>/dev/null; then
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install
    until xcode-select -p &>/dev/null; do
      sleep 5
    done
  fi
fi

# Install Homebrew
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Add Homebrew to PATH for this script
if is_darwin; then
  eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
else
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Clone dotfiles
if [ ! -d "$HOME/.dotfiles" ]; then
  echo "Cloning dotfiles..."
  git clone https://github.com/jruhland/dotfiles.git "$HOME/.dotfiles"
fi

cd "$HOME/.dotfiles"

# Install Homebrew packages
echo "Installing Homebrew packages..."
brew bundle install

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Deploy dotfiles with dotter
echo "Deploying dotfiles..."
export ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
dotter deploy -v

# Install mise
echo "Installing mise..."
curl -fsSL https://mise.run | sh
eval "$("$HOME/.local/bin/mise" activate bash)"
mise install

# Install global npm packages
echo "Installing global npm packages..."
npm install -g @anthropic-ai/claude-code

# Apply macOS settings
if is_darwin; then
  echo "Applying macOS settings..."
  ./macos.sh
fi

echo "Bootstrap complete!"

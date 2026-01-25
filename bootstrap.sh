#!/usr/bin/env bash

set -eu

OS="$(uname -s)"
is_darwin() { [ "$OS" = "Darwin" ]; }
is_linux() { [ "$OS" = "Linux" ]; }

echo "Bootstrapping dotfiles for $OS..."

# Install prerequisites on Ubuntu
if is_linux; then
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ "$ID" = "ubuntu" ]; then
      echo "Installing Ubuntu prerequisites..."
      sudo apt-get update
      sudo apt-get install -y build-essential procps curl file git zsh
    fi
  fi
fi

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
  sudo -v
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
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

# Install gh CLI first (needed for taps that require GitHub auth)
if ! command -v gh &>/dev/null; then
  echo "Installing GitHub CLI..."
  brew install gh
fi

# Authenticate with GitHub if not already (needed for third-party taps)
if ! gh auth status &>/dev/null; then
  echo "GitHub authentication required for Homebrew taps..."
  gh auth login
fi

# Generate SSH key and add to GitHub if not present
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
  echo "Generating SSH key..."
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  ssh-keygen -t ed25519 -f "$HOME/.ssh/id_ed25519" -N "" -q
  echo "Adding SSH key to GitHub..."
  gh ssh-key add "$HOME/.ssh/id_ed25519.pub" --title "$(hostname)"
fi

# Install Homebrew packages
echo "Installing Homebrew packages..."
if is_darwin; then
  brew bundle install --file=Brewfile
else
  brew bundle install --file=Brewfile.linux
fi

# Install 1Password CLI (Linux only, macOS uses cask)
if is_linux; then
  if ! command -v op &>/dev/null; then
    if [ -f /etc/os-release ]; then
      . /etc/os-release
      if [ "$ID" = "ubuntu" ]; then
        echo "Installing 1Password CLI..."
        curl -fsSL https://downloads.1password.com/linux/keys/1password.agilebits.com.gpg.key | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | sudo tee /etc/apt/sources.list.d/1password.sources.list
        sudo mkdir -p /usr/share/debsig/keyrings/1password && curl -fsSL https://downloads.1password.com/linux/debsig/1password.gpg | sudo tee /usr/share/debsig/keyrings/1password/1password.gpg >/dev/null
        sudo apt update && sudo apt install -y 1password-cli
      fi
    fi
  fi
fi

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Deploy dotfiles with dotter
echo "Deploying dotfiles..."
export ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
FORCE_FLAG=""
if [ "${BOOTSTRAP_FORCE:-true}" = "true" ]; then
  FORCE_FLAG="--force"
fi
if is_darwin; then
  dotter deploy -v -l .dotter/macos.toml $FORCE_FLAG
else
  dotter deploy -v -l .dotter/linux.toml $FORCE_FLAG
fi

# Apply macOS settings (before launching Cursor)
if is_darwin; then
  echo "Applying macOS settings..."
  ./macos.sh
fi

# Install Cursor extensions
if [ -f "$HOME/.dotfiles/cursor/install-extensions.sh" ]; then
  echo "Installing Cursor extensions..."
  "$HOME/.dotfiles/cursor/install-extensions.sh"
fi

# Install mise
if [ ! -f "$HOME/.local/bin/mise" ]; then
  echo "Installing mise..."
  curl -fsSL https://mise.run | sh
fi

eval "$("$HOME/.local/bin/mise" activate bash)"
mise install

# Install global npm packages
echo "Installing global npm packages..."
npm install -g @anthropic-ai/claude-code @openai/codex

echo "Bootstrap complete!"

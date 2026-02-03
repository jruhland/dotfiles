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
BREW_INSTALLED=false
if is_darwin; then
  if [ -x /opt/homebrew/bin/brew ] || [ -x /usr/local/bin/brew ]; then
    BREW_INSTALLED=true
  fi
else
  if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    BREW_INSTALLED=true
  fi
fi

if [ "$BREW_INSTALLED" = false ]; then
  echo "Installing Homebrew..."
  sudo -v
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "Homebrew already installed, skipping..."
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

echo "Checking for GitHub CLI..."
if ! command -v gh &>/dev/null; then
  echo "Installing GitHub CLI..."
  brew install gh
fi

echo "Checking GitHub authentication..."
if ! gh auth status &>/dev/null; then
  echo "GitHub authentication required for Homebrew taps..."
  gh auth login --scopes "admin:public_key"

  # Verify authentication succeeded
  if ! gh auth status &>/dev/null; then
    echo "ERROR: GitHub authentication failed. Please run 'gh auth login' manually."
    exit 1
  fi
fi

echo "Checking SSH keys..."
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
  echo "Generating SSH key..."
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  ssh-keygen -t ed25519 -f "$HOME/.ssh/id_ed25519" -N "" -q
else
  echo "SSH key already exists"
fi

# Check if SSH key is on GitHub and add if missing
if [ -f "$HOME/.ssh/id_ed25519.pub" ]; then
  KEY_CONTENT=$(cat "$HOME/.ssh/id_ed25519.pub" | awk '{print $2}')
  if gh ssh-key list | grep -q "$KEY_CONTENT"; then
    echo "SSH key already on GitHub"
  else
    echo "Adding SSH key to GitHub..."
    if gh ssh-key add "$HOME/.ssh/id_ed25519.pub" --title "$(hostname)"; then
      echo "SSH key successfully added to GitHub"
    else
      echo "WARNING: Failed to add SSH key to GitHub. You may need to add it manually."
      echo "Run: gh ssh-key add ~/.ssh/id_ed25519.pub"
    fi
  fi
fi

# Add GitHub to known_hosts to avoid host verification prompts
echo "Checking GitHub in known_hosts..."
mkdir -p "$HOME/.ssh"
touch "$HOME/.ssh/known_hosts"
if ! grep -q "github.com" "$HOME/.ssh/known_hosts"; then
  echo "Adding GitHub to known_hosts..."
  ssh-keyscan -t ed25519 github.com >>"$HOME/.ssh/known_hosts" 2>/dev/null || true
else
  echo "GitHub already in known_hosts"
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
mkdir -p "$HOME/.local/bin"
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

echo "Installing mise tools..."
eval "$("$HOME/.local/bin/mise" activate bash)"
mise install

# Install global npm packages
echo "Installing global npm packages..."
npm install -g @anthropic-ai/claude-code @openai/codex

# Install Claude Code symlink
echo "Setting up Claude Code..."
claude install

# Install opencode
curl -fsSL https://opencode.ai/install | bash

echo "Bootstrap complete!"

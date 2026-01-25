# dotfiles

Your dotfiles. For when it's 3am and you need to bootstrap a new machine.

## Quick Start

```sh
curl -fsSL https://raw.githubusercontent.com/jruhland/dotfiles/main/bootstrap.sh | sh
```

Then restart your terminal and follow **Post-Bootstrap Setup** below.

## What Gets Installed

**Core toolkit:**
- Homebrew + packages (see [Brewfile](./Brewfile))
- gh (GitHub CLI), mise (nodejs, python)
- Neovim, git-spice, jq, ripgrep, bat, eza, fzf, fastfetch
- dotter, zoxide, pgcli, watchman
- Docker (with Colima, buildx, compose, credential helpers)
- 1Password CLI, Claude Code, OpenAI Codex
- Oh My Zsh with zsh-syntax-highlighting, oh-my-posh

**macOS apps:**
- 1Password, Ghostty, Cursor
- Hyperkey, Rectangle Pro, Raycast
- Spotify, Google Chrome, Signal
- UTM (virtualization)
- Maple Mono Nerd Font

**Auto-configured:**
- GitHub CLI authentication (interactive)
- SSH key generation and GitHub upload
- Git commit signing via 1Password SSH agent
- macOS system preferences
- Auto-start on login: Hyperkey, Rectangle Pro, Raycast

## Post-Bootstrap Setup

### 1. Authenticate 1Password CLI

```sh
op signin
```

Git commit signing already configured to use 1Password SSH agent.

### 2. Configure apps manually

**Hyperkey:**
- Remap Caps Lock to Hyper key (⌘⌥⌃⇧)

**Rectangle Pro:**
- Hyper + ← : First two-thirds
- Hyper + → : Last third
- ⌘⌥⌃ + ← : Left half
- ⌘⌥⌃ + → : Right half
- ⌘⌥⌃ + C : Center
- ⌘⌥⌃ + M : Maximize
- Hide menu bar icon

**Raycast:**
- Global hotkey: ⌘ + Space
- Hide menu bar icon

### 3. Verify everything works

```sh
gh auth status              # Should show logged in
op whoami                   # Should show your 1Password account
mise doctor                 # Should show nodejs + python installed
git commit --allow-empty -m "test"  # Should sign via 1Password
```

That's it. Restart your terminal if any commands aren't found.

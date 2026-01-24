# dotfiles

Your dotfiles. For when it's 3am and you need to bootstrap a new machine.

## Quick Start

```sh
curl -fsSL https://raw.githubusercontent.com/jruhland/dotfiles/main/bootstrap.sh | sh
```

Then restart your terminal and follow **Post-Bootstrap Setup** below.

## What Gets Installed

**Development tools:**
- Homebrew + packages (see [Brewfile](./Brewfile))
- mise (nodejs 24.12.0, python 3.14.2)
- Neovim, gh, git-spice, jq, ripgrep, bat, eza, fzf
- Docker + Colima (macOS) or Docker (Linux)
- Docker credential helpers (osxkeychain + ecr-login)

**CLI tools:**
- 1Password CLI (`op`)
- Claude Code (`claude`)
- OpenAI Codex

**Shell:**
- Oh My Zsh
- zoxide, fzf, syntax highlighting
- oh-my-posh theme

**macOS apps:**
- 1Password, Ghostty, Cursor, Signal
- Hyperkey, Rectangle Pro, Raycast
- Chrome, Spotify

**macOS only:**
- System preferences via macos.sh
- Xcode Command Line Tools

## Post-Bootstrap Setup

### 1. Authenticate GitHub CLI

```sh
gh auth login
```

Follow prompts (choose HTTPS, login via browser, paste token).

### 2. Authenticate 1Password CLI

```sh
op signin
```

Enter your 1Password account details. Git commit signing already configured to use 1Password SSH agent.

### 3. Start Docker (macOS only)

```sh
colima start
```

Uses config from `~/.colima/colima.yaml` (2 CPU, 4GB RAM, 100GB disk). Linux users: Docker installed via apt, no Colima needed.

### 4. Docker credentials (auto-configured)

Docker credential helpers automatically configured via `~/.docker/config.json`:
- **Public registries** (Docker Hub, etc): Unauthenticated pulls work
- **GHCR**: `docker login ghcr.io` (macOS uses keychain, Linux stores in plaintext)
- **ECR**: Auto-authenticates via AWS credentials (no manual login needed)

### 5. Setup AWS credentials (if using ECR)

```sh
aws configure
```

Or use `op` to inject credentials:
```sh
export AWS_ACCESS_KEY_ID=$(op read "op://Private/AWS/access_key_id")
export AWS_SECRET_ACCESS_KEY=$(op read "op://Private/AWS/secret_access_key")
```

Docker ECR credential helper will auto-refresh tokens.

### 6. Setup SSH keys (if needed)

Git signing already uses 1Password SSH agent (see `.gitconfig`). For general SSH:

```sh
ssh-keygen -t ed25519 -C "your_email@example.com"
gh ssh-key add ~/.ssh/id_ed25519.pub
```

Or manage via 1Password SSH agent.

### 7. Verify everything works

```sh
gh auth status              # Should show logged in
op whoami                   # Should show your 1Password account
docker ps                   # Should connect to Colima/Docker
mise doctor                 # Should show nodejs + python installed
git commit --allow-empty -m "test"  # Should sign via 1Password
```

## Linux-Specific Notes

- Colima not installed (Linux has native Docker)
- 1Password CLI installed via apt (not Homebrew cask)
- Brewfile.linux used instead of Brewfile (no GUI apps)
- Docker credential helper uses `ecr-login` only (no keychain)

## Troubleshooting

### "docker: command not found" (macOS)

```sh
colima start
```

### "error getting credentials" (Docker)

Install credential helpers (already in Brewfile):
```sh
brew install docker-credential-helper docker-credential-helper-ecr
```

### "gh: command not found" after bootstrap

Restart your terminal to reload PATH.

### mise tools not found

Restart terminal, then:
```sh
mise install
```

## Manual Updates

```sh
cd ~/.dotfiles
git pull
brew bundle install    # macOS
brew bundle install --file=Brewfile.linux  # Linux
dotter deploy -v -l macos   # or -l linux
```

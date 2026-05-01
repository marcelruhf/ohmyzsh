#!/usr/bin/env bash
# Personal zsh config installer.
#
# Clones this fork of oh-my-zsh to ~/.oh-my-zsh, installs third-party
# plugins, and symlinks ~/.zshrc and ~/.zshenv to the tracked dotfiles.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/marcelruhf/ohmyzsh/master/install.sh | bash
#
# Override the repo URL (e.g., to use SSH) via OMZ_FORK_REPO:
#   OMZ_FORK_REPO=git@github.com:marcelruhf/ohmyzsh.git bash install.sh

set -euo pipefail

REPO_URL="${OMZ_FORK_REPO:-https://github.com/marcelruhf/ohmyzsh.git}"
TARGET_DIR="${ZSH:-$HOME/.oh-my-zsh}"

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m  %s\n' "$*" >&2; }
err() { printf '\033[1;31mxx\033[0m  %s\n' "$*" >&2; exit 1; }

command -v git >/dev/null 2>&1 || err "git is required"
command -v zsh >/dev/null 2>&1 || warn "zsh not found in PATH; install it before using this config"

if [[ -d "$TARGET_DIR/.git" ]]; then
  current_origin="$(git -C "$TARGET_DIR" remote get-url origin 2>/dev/null || true)"
  if [[ "$current_origin" != "$REPO_URL" ]]; then
    err "$TARGET_DIR exists with a different origin ($current_origin). Move it aside or update its remote."
  fi
  log "Updating existing clone in $TARGET_DIR"
  git -C "$TARGET_DIR" pull --ff-only
elif [[ -e "$TARGET_DIR" ]]; then
  err "$TARGET_DIR exists and is not a git checkout. Move it aside first."
else
  log "Cloning $REPO_URL into $TARGET_DIR"
  git clone "$REPO_URL" "$TARGET_DIR"
fi

clone_plugin() {
  local repo_url="$1" dest="$2"
  if [[ -d "$dest" ]]; then
    log "Plugin already present: ${dest##*/}"
  else
    log "Installing plugin: ${dest##*/}"
    git clone --depth 1 "$repo_url" "$dest"
  fi
}

clone_plugin https://github.com/zsh-users/zsh-autosuggestions \
  "$TARGET_DIR/custom/plugins/zsh-autosuggestions"
clone_plugin https://github.com/zsh-users/zsh-syntax-highlighting \
  "$TARGET_DIR/custom/plugins/zsh-syntax-highlighting"

link_dotfile() {
  local src="$1" dst="$2"

  if [[ ! -e "$src" ]]; then
    err "Expected source missing: $src"
  fi

  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    log "Already linked: $dst"
    return
  fi

  if [[ -e "$dst" || -L "$dst" ]]; then
    local backup="${dst}.backup.$(date +%Y%m%d-%H%M%S)"
    log "Backing up existing $dst -> $backup"
    mv "$dst" "$backup"
  fi

  ln -s "$src" "$dst"
  log "Linked $dst -> $src"
}

link_dotfile "$TARGET_DIR/custom/dotfiles/zshrc"  "$HOME/.zshrc"
link_dotfile "$TARGET_DIR/custom/dotfiles/zshenv" "$HOME/.zshenv"

log "Done. Start a new shell or run: exec zsh"

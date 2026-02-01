#!/usr/bin/env bash

# Dotfiles Backup Script
# 현재 시스템의 설정 파일을 dotfiles 레포로 복사

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

backup_file() {
    local src="$1"
    local dest="$2"

    if [ -e "$src" ]; then
        mkdir -p "$(dirname "$dest")"
        cp -r "$src" "$dest"
        log_success "Copied: $src -> $dest"
    else
        log_warn "File not found: $src"
    fi
}

echo "=================================="
echo "  Dotfiles Backup Script"
echo "=================================="
echo ""

# Home directory files
log_info "Backing up home directory files..."
backup_file "$HOME/.gitconfig" "$DOTFILES_DIR/home/.gitconfig"
backup_file "$HOME/.zshrc" "$DOTFILES_DIR/home/.zshrc"
backup_file "$HOME/.zprofile" "$DOTFILES_DIR/home/.zprofile"
backup_file "$HOME/.tmux.conf" "$DOTFILES_DIR/home/.tmux.conf"
backup_file "$HOME/.p10k.zsh" "$DOTFILES_DIR/home/.p10k.zsh"
echo ""

# Config directory files
log_info "Backing up config directory files..."
backup_file "$HOME/.config/git" "$DOTFILES_DIR/config/git"
backup_file "$HOME/.config/nvim" "$DOTFILES_DIR/config/nvim"
echo ""

# Claude Code settings (settings.json only)
log_info "Backing up Claude Code settings..."
if [ -f "$HOME/.claude/settings.json" ]; then
    backup_file "$HOME/.claude/settings.json" "$DOTFILES_DIR/claude/settings.json"
else
    log_warn "Claude settings not found at $HOME/.claude/settings.json"
fi
echo ""

# SSH config template (remove sensitive info)
log_info "Creating SSH config template..."
if [ -f "$HOME/.ssh/config" ]; then
    mkdir -p "$DOTFILES_DIR/ssh"
    cat > "$DOTFILES_DIR/ssh/config.template" << 'EOF'
# SSH Config Template
# Copy this file to ~/.ssh/config and customize for your machine

# Example configuration:
# Host example
#     HostName example.com
#     User your-username
#     IdentityFile ~/.ssh/id_ed25519
#     Port 22

EOF
    log_success "Created SSH config template"
    log_warn "Please manually edit ssh/config.template to remove sensitive information"
else
    log_warn "SSH config not found at $HOME/.ssh/config"
fi
echo ""

echo "=================================="
log_success "Backup completed!"
echo "=================================="
echo ""
echo "Next steps:"
echo "1. Review the backed up files"
echo "2. Check ssh/config.template and remove any sensitive info"
echo "3. Commit changes: git add . && git commit -m 'Update dotfiles'"
echo "4. Push to remote: git push"

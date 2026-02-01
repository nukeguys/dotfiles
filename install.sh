#!/usr/bin/env bash

# Dotfiles Installation Script
# Symlink로 dotfiles를 홈 디렉토리에 연결

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

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

backup_existing() {
    local file="$1"

    if [ -e "$file" ] && [ ! -L "$file" ]; then
        mkdir -p "$BACKUP_DIR"
        local backup_path="$BACKUP_DIR/$(basename "$file")"
        mv "$file" "$backup_path"
        log_warn "Backed up existing file: $file -> $backup_path"
        return 0
    fi
    return 1
}

create_symlink() {
    local src="$1"
    local dest="$2"

    # Check if source exists
    if [ ! -e "$src" ]; then
        log_warn "Source does not exist: $src"
        return 1
    fi

    # Create parent directory if needed
    mkdir -p "$(dirname "$dest")"

    # Backup existing file if it's not a symlink
    backup_existing "$dest"

    # Remove existing symlink if present
    if [ -L "$dest" ]; then
        rm "$dest"
    fi

    # Create symlink
    ln -sf "$src" "$dest"
    log_success "Linked: $dest -> $src"
}

echo "=================================="
echo "  Dotfiles Installation Script"
echo "=================================="
echo ""

# Home directory files
log_info "Installing home directory dotfiles..."
create_symlink "$DOTFILES_DIR/home/.gitconfig" "$HOME/.gitconfig"
create_symlink "$DOTFILES_DIR/home/.zshrc" "$HOME/.zshrc"
create_symlink "$DOTFILES_DIR/home/.zprofile" "$HOME/.zprofile"
create_symlink "$DOTFILES_DIR/home/.tmux.conf" "$HOME/.tmux.conf"
create_symlink "$DOTFILES_DIR/home/.p10k.zsh" "$HOME/.p10k.zsh"
echo ""

# Config directory
log_info "Installing config directory files..."
create_symlink "$DOTFILES_DIR/config/git" "$HOME/.config/git"
create_symlink "$DOTFILES_DIR/config/nvim" "$HOME/.config/nvim"
echo ""

# Claude Code settings
log_info "Installing Claude Code settings..."
echo ""
read -p "Do you want to sync Claude Code settings? (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    create_symlink "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"
else
    log_info "Skipped Claude Code settings"
fi
echo ""

# SSH config reminder
log_warn "SSH config is not automatically installed for security reasons"
log_info "To setup SSH config:"
echo "  1. Copy the template: cp $DOTFILES_DIR/ssh/config.template ~/.ssh/config"
echo "  2. Edit ~/.ssh/config with your SSH keys and hosts"
echo "  3. Set permissions: chmod 600 ~/.ssh/config"
echo ""

echo "=================================="
log_success "Installation completed!"
echo "=================================="
echo ""

if [ -d "$BACKUP_DIR" ]; then
    echo "Original files backed up to: $BACKUP_DIR"
    echo ""
fi

echo "Next steps:"
echo "1. Restart your shell or run: source ~/.zshrc"
echo "2. Setup SSH config (see instructions above)"
echo "3. For Neovim: Open nvim and run :Lazy sync to install plugins"

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

Personal dotfiles management system for synchronizing development environment configurations across multiple computers using symlink-based approach. Supports machine-specific settings through local config files.

## Core Architecture

### Two-Script System

**backup.sh**: Copies current system configs → dotfiles repo
- Runs from dotfiles directory
- Uses `DOTFILES_DIR` to determine script location
- Copies files from `$HOME` to repo structure
- Creates SSH config template (not actual config)

**install.sh**: Creates symlinks from dotfiles repo → system
- Creates timestamped backup: `~/.dotfiles-backup-YYYYMMDD-HHMMSS/`
- Only backs up non-symlink files
- Interactive prompt for Claude Code settings sync
- SSH config not auto-installed (security)

### Local Config Pattern

**Problem**: Path dependencies (`/Users/username/...`), Homebrew paths (Intel vs Apple Silicon), tool-specific configs

**Solution**: Split config files:
- `.zshrc` - Common settings (committed to git)
- `.zshrc.local` - Machine-specific settings (gitignored)
- `.zshrc.local.example` - Template (committed as example)

`.zshrc` loads `.zshrc.local` at end if it exists. Uses conditional loading:
```bash
if command -v tool &> /dev/null; then
  # tool-specific config
fi
```

### Directory Mapping

```
dotfiles/home/.gitconfig    → ~/.gitconfig
dotfiles/home/.zshrc        → ~/.zshrc
dotfiles/config/git/        → ~/.config/git/
dotfiles/config/nvim/       → ~/.config/nvim/
dotfiles/claude/settings.json → ~/.claude/settings.json
```

## Common Commands

### Install dotfiles on new machine
```bash
./install.sh
```

### Update repo with local changes
```bash
./backup.sh
git add .
git commit -m "Update dotfiles"
git push
```

### Setup local config (after install)
```bash
cp home/.zshrc.local.example ~/.zshrc.local
vim ~/.zshrc.local  # Add machine-specific settings
```

### Verify symlinks
```bash
ls -la ~ | grep '\->'
ls -la ~/.config/ | grep '\->'
```

## Critical Security Rules

**Never commit these files**:
- `~/.ssh/config` - Use `ssh/config.template` instead
- `~/.claude/.credentials.json` - OAuth tokens
- `*.local` files - Machine-specific configs with API keys
- `.DS_Store`, `*.zwc`, `.zcompdump*`

**Always gitignore**:
- Claude Code session data: `**/projects/`, `**/cache/`, `**/history.jsonl`
- Claude plugins: `**/plugins/` (4.9MB, auto-downloaded)
- Local configs: `*.local`, `*.private`

## Modifying Scripts

### When adding new config files

**In backup.sh**:
```bash
backup_file "$HOME/.newconfig" "$DOTFILES_DIR/home/.newconfig"
```

**In install.sh**:
```bash
create_symlink "$DOTFILES_DIR/home/.newconfig" "$HOME/.newconfig"
```

### When adding machine-specific settings

Add to `home/.zshrc.local.example` with commented examples, NOT to `.zshrc`.

Use `$HOME` instead of hardcoded paths:
```bash
# Bad
export PATH="/Users/username/.tool/bin:$PATH"

# Good
export PATH="$HOME/.tool/bin:$PATH"
```

Use conditional loading for optional tools:
```bash
if command -v tool &> /dev/null; then
  eval "$(tool init)"
fi
```

## Script Patterns

Both scripts use shared logging functions:
- `log_info()` - Blue, informational
- `log_success()` - Green, completed actions
- `log_warn()` - Yellow, skipped/non-critical
- `log_error()` - Red, failures

Scripts are idempotent - safe to run multiple times.

## Repository Structure

- `home/` - Dotfiles for `~/` (gitconfig, zshrc, tmux.conf, p10k.zsh)
- `config/` - Dotfiles for `~/.config/` (git, nvim)
- `claude/` - Claude Code settings (settings.json only, NOT .credentials.json)
- `ssh/` - SSH config template (NOT actual config)
- `docs/` - Setup documentation for new machines
- `backup.sh` - System → repo sync
- `install.sh` - Repo → system sync via symlinks

## Neovim Configuration

Uses LazyVim setup in `config/nvim/`. After install, run `:Lazy sync` in nvim to install plugins.

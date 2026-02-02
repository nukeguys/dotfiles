#!/bin/bash
# Claude Code 설정 symlink 설치 스크립트

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

# 기존 설정 백업
backup_if_exists() {
    if [ -e "$1" ] && [ ! -L "$1" ]; then
        mv "$1" "$1.backup.$(date +%Y%m%d%H%M%S)"
        echo "Backed up: $1"
    fi
}

# ~/.claude 디렉토리 생성
mkdir -p "$CLAUDE_DIR"

# 각 파일에 대해 symlink 생성
for file in settings.json statusline-command.sh; do
    target="$CLAUDE_DIR/$file"
    source="$DOTFILES_DIR/.claude/$file"

    backup_if_exists "$target"
    ln -sf "$source" "$target"
    echo "Linked: $target -> $source"
done

echo "Done!"

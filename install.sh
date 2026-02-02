#!/bin/bash
# Dotfiles 모듈식 설치 스크립트

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# 색상 정의
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 기존 설정 백업
backup_if_exists() {
    if [ -e "$1" ] && [ ! -L "$1" ]; then
        mv "$1" "$1.backup.$(date +%Y%m%d%H%M%S)"
        echo -e "${YELLOW}Backed up:${NC} $1"
    fi
}

# Claude Code 설정 설치
install_claude() {
    echo -e "\n${GREEN}Installing Claude Code settings...${NC}"

    local claude_dir="$HOME/.claude"
    mkdir -p "$claude_dir"

    for file in settings.json statusline-command.sh; do
        local target="$claude_dir/$file"
        local source="$DOTFILES_DIR/.claude/$file"

        if [ -f "$source" ]; then
            backup_if_exists "$target"
            ln -sf "$source" "$target"
            echo "  Linked: $target -> $source"
        else
            echo -e "  ${RED}Not found:${NC} $source"
        fi
    done
}

# Ghostty 설정 설치
install_ghostty() {
    echo -e "\n${GREEN}Installing Ghostty settings...${NC}"

    local config_dir="$HOME/.config/ghostty"
    local app_config_dir="$HOME/Library/Application Support/com.mitchellh.ghostty"
    local source="$DOTFILES_DIR/.config/ghostty/config"

    # 1. ~/.config/ghostty 디렉토리 생성
    mkdir -p "$config_dir"

    # 2. dotfiles -> ~/.config/ghostty/config
    local user_config="$config_dir/config"
    backup_if_exists "$user_config"
    ln -sf "$source" "$user_config"
    echo "  Linked: $user_config -> $source"

    # 3. macOS 앱 설정 경로에 symlink (체인 방식)
    if [ -d "$app_config_dir" ] || [ "$(uname)" = "Darwin" ]; then
        mkdir -p "$app_config_dir"
        local app_config="$app_config_dir/config"
        backup_if_exists "$app_config"
        ln -sf "$user_config" "$app_config"
        echo "  Linked: $app_config -> $user_config"
    fi
}

# 사용법 표시
usage() {
    echo "Usage: ./install.sh [module...]"
    echo ""
    echo "Modules:"
    echo "  claude    Claude Code settings (~/.claude)"
    echo "  ghostty   Ghostty terminal settings (~/.config/ghostty)"
    echo "  all       Install all modules (default)"
    echo ""
    echo "Examples:"
    echo "  ./install.sh          # Install all"
    echo "  ./install.sh claude   # Claude Code only"
    echo "  ./install.sh ghostty  # Ghostty only"
}

# 메인 로직
main() {
    echo "=== Dotfiles Installer ==="

    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        usage
        exit 0
    fi

    if [ $# -eq 0 ] || [ "$1" = "all" ]; then
        install_claude
        install_ghostty
    else
        for module in "$@"; do
            case "$module" in
                claude)  install_claude ;;
                ghostty) install_ghostty ;;
                *)
                    echo -e "${RED}Unknown module:${NC} $module"
                    usage
                    exit 1
                    ;;
            esac
        done
    fi

    echo -e "\n${GREEN}Done!${NC}"
}

main "$@"

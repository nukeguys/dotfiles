#!/bin/bash
# Dotfiles 모듈식 설치 스크립트

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# 색상 정의
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 기존 설정 백업 (백업 경로를 stdout으로 반환)
backup_if_exists() {
    if [ -e "$1" ] && [ ! -L "$1" ]; then
        local backup_path="$1.backup.$(date +%Y%m%d%H%M%S)"
        mv "$1" "$backup_path"
        echo "$backup_path"
    fi
}

# 심링크 생성 (이미 올바른 심링크면 스킵)
link_file() {
    local source="$1"
    local target="$2"

    if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
        echo -e "  ${BLUE}Already linked:${NC} $target"
        return
    fi

    local backed_up
    backed_up=$(backup_if_exists "$target")
    ln -sf "$source" "$target"
    echo -e "  ${GREEN}Linked:${NC} $target -> $source"
    if [ -n "$backed_up" ]; then
        echo -e "   └${YELLOW} Backed up:${NC} $backed_up"
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
            link_file "$source" "$target"
        else
            echo -e "  ${RED}Not found:${NC} $source"
        fi
    done

    # 글로벌 Claude 설정 (GLOBAL-AGENTS.md -> ~/.claude/CLAUDE.md)
    local claude_md_target="$claude_dir/CLAUDE.md"
    local claude_md_source="$DOTFILES_DIR/GLOBAL-AGENTS.md"

    if [ -f "$claude_md_source" ]; then
        link_file "$claude_md_source" "$claude_md_target"
    else
        echo -e "  ${RED}Not found:${NC} $claude_md_source"
    fi
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
    link_file "$source" "$user_config"

    # 3. macOS 앱 설정 경로에 symlink (체인 방식)
    if [ -d "$app_config_dir" ] || [ "$(uname)" = "Darwin" ]; then
        mkdir -p "$app_config_dir"
        local app_config="$app_config_dir/config"
        link_file "$user_config" "$app_config"
    fi
}

# Gemini 설정 설치
install_gemini() {
    echo -e "\n${GREEN}Installing Gemini settings...${NC}"

    local gemini_dir="$HOME/.gemini"
    mkdir -p "$gemini_dir"

    # 글로벌 Gemini 설정 (GLOBAL-AGENTS.md -> ~/.gemini/GEMINI.md)
    local gemini_md_target="$gemini_dir/GEMINI.md"
    local gemini_md_source="$DOTFILES_DIR/GLOBAL-AGENTS.md"

    if [ -f "$gemini_md_source" ]; then
        link_file "$gemini_md_source" "$gemini_md_target"
    else
        echo -e "  ${RED}Not found:${NC} $gemini_md_source"
    fi
}

# 사용법 표시
usage() {
    echo "Usage: ./install.sh [module...]"
    echo ""
    echo "Modules:"
    echo "  claude    Claude Code settings (~/.claude)"
    echo "  ghostty   Ghostty terminal settings (~/.config/ghostty)"
    echo "  gemini    Gemini settings (~/.gemini)"
    echo "  all       Install all modules (default)"
    echo ""
    echo "Examples:"
    echo "  ./install.sh          # Install all"
    echo "  ./install.sh claude   # Claude Code only"
    echo "  ./install.sh ghostty  # Ghostty only"
    echo "  ./install.sh gemini   # Gemini only"
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
        install_gemini
    else
        for module in "$@"; do
            case "$module" in
                claude)  install_claude ;;
                ghostty) install_ghostty ;;
                gemini)  install_gemini ;;
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

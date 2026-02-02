# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 저장소 개요

개인 개발 환경 설정(dotfiles)을 관리하는 저장소입니다. symlink를 통해 여러 컴퓨터에서 동일한 설정을 유지합니다.

## 주요 명령어

```bash
# 전체 설치
./install.sh

# 모듈별 선택 설치
./install.sh claude    # Claude Code 설정만
./install.sh ghostty   # Ghostty 터미널 설정만

# 도움말
./install.sh --help
```

## 구조

```
dotfiles/
├── .claude/                    # Claude Code 전역 설정
│   ├── settings.json           # statusline 등 전역 설정
│   └── statusline-command.sh   # 커스텀 statusline 스크립트
├── .config/
│   └── ghostty/config          # Ghostty 터미널 설정
└── install.sh                  # 모듈식 설치 스크립트
```

## Symlink 패턴

설치 스크립트는 체인 방식 symlink를 사용합니다:

**Claude Code:**
- `~/.claude/{file}` → `dotfiles/.claude/{file}`

**Ghostty (macOS):**
- `~/.config/ghostty/config` → `dotfiles/.config/ghostty/config`
- `~/Library/Application Support/com.mitchellh.ghostty/config` → `~/.config/ghostty/config`

## 새 모듈 추가 시

1. `install.sh`에 `install_모듈명()` 함수 추가
2. `main()` 함수의 case 문에 모듈 추가
3. `usage()` 함수에 모듈 설명 추가
4. README.md 업데이트

## 의존성

- `jq`: statusline 스크립트에서 JSON 파싱에 사용
- `bc`: 비용 계산에 사용

## 주의사항

- `.credentials.json`은 절대 커밋 금지 (OAuth 토큰 포함)
- 기존 파일이 있으면 자동으로 `.backup.{timestamp}` 형식으로 백업됨

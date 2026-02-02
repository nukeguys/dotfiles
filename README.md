# Dotfiles

개인 개발 환경 설정을 관리하는 저장소입니다. symlink를 통해 여러 컴퓨터에서 동일한 설정을 유지합니다.

## 설치 방법

```bash
# 저장소 클론
git clone https://github.com/nukeguys/dotfiles.git ~/Projects/dotfiles

# 전체 설치
cd ~/Projects/dotfiles
./install.sh

# 또는 선택 설치
./install.sh claude    # Claude Code만
./install.sh ghostty   # Ghostty만
```

## 포함된 설정

### Claude Code (`.claude/`)

Claude Code 전역 설정 파일들입니다.

| 파일 | 설명 |
|------|------|
| `settings.json` | 전역 설정 (커스텀 statusline 활성화) |
| `statusline-command.sh` | 커스텀 statusline 스크립트 |

**Statusline 표시 정보:**
- 현재 디렉토리
- Git 브랜치 및 상태 (dirty, ahead/behind)
- 사용 중인 모델
- Output style
- 컨텍스트 사용량 (입력/출력 토큰 분리, 사용률에 따른 색상 변화)
- 비용 (금액에 따른 색상 변화)

**색상 표시:**

| 구분 | 초록 | 노랑 | 주황 | 빨강 |
|------|------|------|------|------|
| 컨텍스트 | 0-49% | 50-79% | - | 80%+ |
| 비용 | - | $0.50 미만 | $0.50-$1.99 | $2.00+ |

**아이콘 설정:**

```bash
# ~/.zshrc에 추가
export CLAUDE_STATUSLINE_ICONS=unicode  # 이모지 사용
# 또는
export CLAUDE_STATUSLINE_ICONS=none     # 아이콘 없음
```

| 옵션 | 설명 | 예시 |
|------|------|------|
| `nerd` (기본) | Nerd Font 아이콘 | 󰉋  󰘦  󰄀 |
| `unicode` | 이모지 | 📁 ⎇ 🤖 📊 💰 |
| `none` | 텍스트만 | (아이콘 없음) |

### Ghostty (`.config/ghostty/`)

[Ghostty](https://ghostty.org/) 터미널 에뮬레이터 설정입니다.

| 설정 | 값 |
|------|------|
| 테마 | Snazzy |
| 투명도 | 0.9 |
| 폰트 | MesloLGS Nerd Font + Noto Sans KR |
| 스크롤백 | 100,000줄 |

**Symlink 구조:**
```
dotfiles/.config/ghostty/config
    ↓ symlink
~/.config/ghostty/config
    ↓ symlink
~/Library/Application Support/com.mitchellh.ghostty/config
```

## 검증

```bash
# Claude Code symlink 확인
ls -la ~/.claude/settings.json
ls -la ~/.claude/statusline-command.sh

# Ghostty symlink 확인
ls -la ~/.config/ghostty/config
ls -la ~/Library/Application\ Support/com.mitchellh.ghostty/config
```

## 의존성

- `jq`: JSON 파싱 (`brew install jq`)
- [Nerd Font](https://www.nerdfonts.com/): 아이콘 표시 (선택)

## 주의사항

- `.credentials.json` 파일은 절대 커밋하지 마세요 (OAuth 토큰 포함)
- Ghostty 설정 변경 후 `Cmd + Shift + ,`로 리로드 가능

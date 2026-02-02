# Claude Code Settings

이 저장소는 Claude Code 전역 설정을 관리하고 symlink로 다른 컴퓨터에 적용할 수 있도록 구성합니다.

## 포함된 설정

### .claude/settings.json

전역 설정 파일입니다. 커스텀 statusline을 사용하도록 설정되어 있습니다.

### .claude/statusline-command.sh

커스텀 statusline 스크립트입니다. 다음 정보를 표시합니다:

- 현재 디렉토리
- Git 브랜치 및 상태 (dirty, ahead/behind)
- 사용 중인 모델
- 컨텍스트 사용량
- 비용

## 설치 방법

```bash
# 저장소 클론
git clone https://github.com/nukeguys/dotfiles.git ~/Projects/dotfiles

# 설치 스크립트 실행
cd ~/Projects/dotfiles
./install.sh
```

설치 스크립트는 다음을 수행합니다:

1. 기존 파일이 있으면 백업 (`*.backup.YYYYMMDDHHMMSS`)
2. `~/.claude/settings.json` → dotfiles로 symlink
3. `~/.claude/statusline-command.sh` → dotfiles로 symlink

## 검증

```bash
# symlink 확인
ls -la ~/.claude/settings.json
ls -la ~/.claude/statusline-command.sh

# Claude Code 재시작하여 statusline 확인
```

## 주의사항

- `.credentials.json` 파일은 절대 커밋하지 마세요 (OAuth 토큰 포함)
- statusline 스크립트는 [Nerd Font](https://www.nerdfonts.com/)가 설치되어 있어야 아이콘이 정상 표시됩니다
- `jq` 명령어가 필요합니다 (`brew install jq`)

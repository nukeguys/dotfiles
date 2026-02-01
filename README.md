# Dotfiles

개인 개발 환경 설정을 여러 컴퓨터에서 동기화하기 위한 dotfiles 저장소입니다.

## 포함된 설정

### 홈 디렉토리 (~/)

- `.gitconfig` - Git 전역 설정
- `.zshrc` - Zsh 쉘 설정
- `.zprofile` - Zsh 프로파일
- `.tmux.conf` - Tmux 설정
- `.p10k.zsh` - Powerlevel10k 테마 설정

### XDG Config (~/.config/)

- `git/` - Git 추가 설정 (global ignore 등)
- `nvim/` - Neovim 전체 설정 (플러그인 포함)

### Claude Code (~/.claude/)

- `settings.json` - 모델 설정 (24B)

### SSH (~/.ssh/)

- `config.template` - SSH 설정 템플릿 (수동 설정 필요)

## 설치 방법

### 사전 준비

새 컴퓨터에서 처음 설정하는 경우:

```bash
# Homebrew 설치 (macOS)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# iTerm2 설치 (권장)
brew install --cask iterm2

# 기본 도구 설치
brew install git tig zsh tmux neovim

# 유용한 CLI 도구
brew install bat fzf ripgrep lazydocker glances

# Oh My Zsh 설치
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Powerlevel10k 테마 설치
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

### Dotfiles 설치

```bash
# 1. 저장소 클론
git clone git@github.com:nukeguys/dotfiles.git ~/Projects/dotfiles
cd ~/Projects/dotfiles

# 2. 설치 스크립트 실행
./install.sh

# 3. 쉘 재시작
source ~/.zshrc
```

설치 스크립트는:

- 기존 파일을 자동으로 백업합니다 (`~/.dotfiles-backup-TIMESTAMP/`)
- Symlink를 생성하여 dotfiles를 연결합니다
- Claude Code 설정 동기화 여부를 물어봅니다

### SSH 설정 (수동)

```bash
# SSH config 템플릿 복사
cp ~/Projects/dotfiles/ssh/config.template ~/.ssh/config

# 파일 편집 (SSH 키 경로, 호스트 정보 등)
vim ~/.ssh/config

# 권한 설정
chmod 600 ~/.ssh/config
```

### 로컬 설정 (컴퓨터별 설정)

경로나 환경이 다른 컴퓨터에서 사용하기 위해 로컬 설정 파일을 지원합니다.

```bash
# 템플릿 복사
cp ~/Projects/dotfiles/home/.zshrc.local.example ~/.zshrc.local

# 파일 편집 (컴퓨터별 PATH, 환경변수, alias 등)
vim ~/.zshrc.local
```

`.zshrc.local`에 추가할 수 있는 것들:
- 컴퓨터별 PATH 설정
- API 키 및 인증 정보
- 프로젝트별 alias
- 도구별 설정 (Antigravity, OpenCode 등)

**중요**: `.zshrc.local`은 Git에 추적되지 않으므로 각 컴퓨터에서 직접 설정해야 합니다.

## 설정 업데이트

로컬에서 설정을 변경한 후 저장소에 반영하려면:

```bash
cd ~/Projects/dotfiles

# 1. 변경사항 백업
./backup.sh

# 2. 변경사항 확인
git status
git diff

# 3. 커밋 및 푸시
git add .
git commit -m "Update dotfiles"
git push
```

## 제외된 파일

다음 파일들은 보안/효율성을 위해 저장소에 포함되지 않습니다:

### 자동 제외 (.gitignore)

- `~/.claude/.credentials.json` - OAuth 토큰
- `~/.claude/plugins/` - 4.9MB, 각 컴퓨터에서 자동 다운로드됨
- `~/.claude/projects/` - 세션별 프로젝트 데이터
- `~/.claude/cache/`, `history.jsonl` 등 - 캐시 및 세션 데이터
- `*.local` - 컴퓨터별 설정 파일 (.zshrc.local 등)

### 수동 설정 필요

- `~/.ssh/config` - SSH 키 경로는 컴퓨터마다 다를 수 있음
- `~/.claude.json` - 사용자 계정 정보 포함 (선택적)
- `~/.zshrc.local` - 컴퓨터별 쉘 설정 (템플릿 제공)

## 디렉토리 구조

```text
dotfiles/
├── README.md              # 이 문서
├── install.sh             # Symlink 생성 스크립트
├── backup.sh              # 설정 파일 백업 스크립트
├── .gitignore             # 제외 파일 목록
│
├── home/                  # 홈 디렉토리 dotfiles
│   ├── .gitconfig
│   ├── .zshrc
│   ├── .zprofile
│   ├── .tmux.conf
│   └── .p10k.zsh
│
├── config/                # ~/.config/ 설정
│   ├── git/
│   └── nvim/
│
├── claude/                # Claude Code 설정
│   └── settings.json
│
├── ssh/                   # SSH 설정
│   └── config.template
│
└── docs/                  # 문서
    └── SETUP.md           # 상세 설정 가이드
```

## 새 컴퓨터 설정 체크리스트

자세한 내용은 [docs/SETUP.md](docs/SETUP.md)를 참고하세요.

- [ ] Homebrew 설치
- [ ] iTerm2 설치 (권장)
- [ ] Git, tig, Zsh, Tmux, Neovim 설치
- [ ] 유용한 CLI 도구 설치 (bat, lazydocker, glances 등)
- [ ] Oh My Zsh + Powerlevel10k 설치
- [ ] Dotfiles 클론 및 install.sh 실행
- [ ] SSH 키 생성 및 config 설정
- [ ] Claude Code 로그인
- [ ] Neovim 플러그인 설치 (`:Lazy sync`)

## 트러블슈팅

### Symlink 확인

```bash
# 홈 디렉토리
ls -la ~ | grep '\->'

# Config 디렉토리
ls -la ~/.config/ | grep '\->'
```

### 원래 파일 복원

```bash
# 백업 디렉토리 찾기
ls -la ~ | grep dotfiles-backup

# 특정 파일 복원
cp ~/.dotfiles-backup-YYYYMMDD-HHMMSS/.gitconfig ~/
```

### Neovim 플러그인 오류

```bash
# Neovim 실행 후
:Lazy sync
:checkhealth
```

## 라이선스

MIT

## 참고

- [GitHub dotfiles](https://dotfiles.github.io/)
- [Awesome dotfiles](https://github.com/webpro/awesome-dotfiles)

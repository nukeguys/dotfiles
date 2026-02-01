# 새 컴퓨터 초기 설정 가이드

이 문서는 새로운 macOS 컴퓨터에서 개발 환경을 처음부터 설정하는 전체 과정을 안내합니다.

## 목차

1. [시스템 기본 설정](#1-시스템-기본-설정)
2. [필수 도구 설치](#2-필수-도구-설치)
3. [Dotfiles 설치](#3-dotfiles-설치)
4. [SSH 설정](#4-ssh-설정)
5. [Claude Code 설정](#5-claude-code-설정)
6. [Neovim 설정](#6-neovim-설정)
7. [검증 및 테스트](#7-검증-및-테스트)

---

## 1. 시스템 기본 설정

### macOS 시스템 업데이트

```bash
# 시스템 업데이트 확인
softwareupdate -l

# 업데이트 설치
sudo softwareupdate -ia
```

### Xcode Command Line Tools 설치

```bash
xcode-select --install
```

---

## 2. 필수 도구 설치

### iTerm2 설치 (권장)

macOS 기본 터미널 대신 iTerm2 사용을 권장합니다.

```bash
# Homebrew Cask를 통한 설치
brew install --cask iterm2
```

iTerm2 설정:

1. Preferences → Profiles → Text → Font를 `MesloLGS NF`로 변경
2. Preferences → Profiles → Colors에서 원하는 테마 선택

### Homebrew 설치

```bash
# Homebrew 설치
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# PATH 설정 (Apple Silicon Mac의 경우)
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# Homebrew 동작 확인
brew doctor
```

### 기본 CLI 도구 설치

```bash
# Git 및 Git TUI
brew install git tig

# Zsh (macOS에 기본 포함되어 있지만 최신 버전 설치)
brew install zsh

# Tmux
brew install tmux

# Neovim
brew install neovim

# 개발 도구
brew install fzf ripgrep fd bat eza

# Docker 관리 도구
brew install lazydocker

# 시스템 모니터링
brew install glances
```

### Oh My Zsh 설치

```bash
# Oh My Zsh 설치
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### Powerlevel10k 테마 설치

```bash
# Powerlevel10k 클론
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# 폰트 설치 (권장)
brew tap homebrew/cask-fonts
brew install --cask font-meslo-lg-nerd-font
```

터미널 앱의 폰트를 `MesloLGS NF`로 변경합니다.

---

## 3. Dotfiles 설치

### 저장소 클론

```bash
# Projects 디렉토리 생성
mkdir -p ~/Projects
cd ~/Projects

# Dotfiles 클론
git clone git@github.com:nukeguys/dotfiles.git
cd dotfiles
```

### 설치 스크립트 실행

```bash
# 설치 스크립트 실행
./install.sh
```

스크립트는 다음을 수행합니다:

1. 기존 파일을 `~/.dotfiles-backup-TIMESTAMP/`로 백업
2. Symlink 생성
3. Claude Code 설정 동기화 여부 확인

### Symlink 확인

```bash
# 홈 디렉토리 dotfiles
ls -la ~ | grep '\->'

# Config 디렉토리
ls -la ~/.config/ | grep '\->'

# 예상 출력:
# .gitconfig -> /Users/username/Projects/dotfiles/home/.gitconfig
# .zshrc -> /Users/username/Projects/dotfiles/home/.zshrc
```

### 쉘 재시작

```bash
# Zsh 재시작
exec zsh

# 또는 source
source ~/.zshrc
```

Powerlevel10k 설정 마법사가 실행되면 안내에 따라 설정합니다.

### 로컬 설정 파일 생성

컴퓨터별 설정을 위한 `.zshrc.local` 파일을 생성합니다.

```bash
# 템플릿 복사
cp ~/Projects/dotfiles/home/.zshrc.local.example ~/.zshrc.local

# 파일 편집
vim ~/.zshrc.local
```

`.zshrc.local`에 추가할 내용 예시:

```bash
# 컴퓨터별 PATH 설정
export PATH="$HOME/.local/bin:$PATH"

# 도구별 설정
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# 커스텀 alias
alias work="cd $HOME/Work"

# API 키 (절대 git에 커밋하지 말 것!)
# export OPENAI_API_KEY="your-key-here"
```

**중요 사항**:
- `.zshrc.local`은 Git에서 추적되지 않습니다 (`.gitignore`에 포함)
- 각 컴퓨터마다 별도로 설정해야 합니다
- API 키나 인증 정보를 안전하게 저장할 수 있습니다

---

## 4. SSH 설정

### SSH 키 생성

```bash
# SSH 디렉토리 생성
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# ED25519 키 생성 (권장)
ssh-keygen -t ed25519 -C "your-email@example.com"

# 또는 RSA 키 생성
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"

# 키 확인
ls -la ~/.ssh/
```

### SSH Config 설정

```bash
# 템플릿 복사
cp ~/Projects/dotfiles/ssh/config.template ~/.ssh/config

# Config 편집
vim ~/.ssh/config
```

예시 설정:

```bash
# GitHub
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    AddKeysToAgent yes

# Personal Server
Host myserver
    HostName example.com
    User your-username
    IdentityFile ~/.ssh/id_ed25519
    Port 22
```

```bash
# 권한 설정
chmod 600 ~/.ssh/config
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```

### GitHub에 SSH 키 등록

```bash
# 공개 키 복사
cat ~/.ssh/id_ed25519.pub | pbcopy
```

1. GitHub → Settings → SSH and GPG keys
2. "New SSH key" 클릭
3. 복사한 공개 키 붙여넣기

```bash
# 연결 테스트
ssh -T git@github.com
```

---

## 5. Claude Code 설정

### Claude Code 설치

```bash
# Claude Code 설치 (Homebrew)
brew install claude

# 버전 확인
claude --version
```

### 로그인

```bash
# Claude Code 로그인
claude auth login
```

브라우저가 열리면 인증을 완료합니다.

### 설정 확인

```bash
# 설정 파일 확인
cat ~/.claude/settings.json

# Credentials 확인 (자동 생성됨)
ls -la ~/.claude/.credentials.json
```

**중요**: `.credentials.json`은 절대 Git에 커밋하지 마세요!

---

## 6. Neovim 설정

### Neovim 플러그인 설치

Dotfiles의 Neovim 설정은 [lazy.nvim](https://github.com/folke/lazy.nvim) 플러그인 매니저를 사용합니다.

```bash
# Neovim 실행
nvim

# 플러그인 자동 설치 (lazy.nvim이 부트스트랩됨)
# 또는 명령어로 직접 실행:
:Lazy sync
```

### 건강 검진

```bash
# Neovim 내에서
:checkhealth
```

문제가 있으면 출력을 확인하여 필요한 도구를 설치합니다.

### 추가 도구 설치 (선택)

```bash
# LSP 서버 (언어별로 필요)
brew install node        # For TypeScript, JavaScript
brew install python3     # For Python
brew install rust        # For Rust

# Formatters
brew install stylua      # Lua formatter
npm install -g prettier  # Multi-language formatter

# Linters
npm install -g eslint    # JavaScript linter
```

---

## 7. 검증 및 테스트

### Git 설정 확인

```bash
# Git 설정 확인
git config --list --show-origin

# 사용자 정보 확인
git config user.name
git config user.email
```

### Zsh 설정 확인

```bash
# Zsh 버전
zsh --version

# 테마 확인
echo $ZSH_THEME

# Aliases 확인
alias
```

### Tmux 설정 확인

```bash
# Tmux 실행
tmux

# 설정 재로드 (tmux 내에서)
# Prefix 키 (기본: Ctrl+B) + : 입력 후
source-file ~/.tmux.conf
```

### Claude Code 설정 확인

```bash
# Claude Code 실행
claude

# 모델 확인 (settings.json에서 설정한 모델 사용)
# 간단한 테스트
echo "console.log('Hello, World!');" | claude "이 코드 설명해줘"
```

### Neovim 설정 확인

```bash
# Neovim 실행
nvim test.md

# 플러그인 상태 확인
:Lazy

# LSP 상태 확인
:LspInfo

# 건강 검진
:checkhealth
```

---

## 체크리스트

### 필수 단계

- [ ] Xcode Command Line Tools 설치
- [ ] Homebrew 설치
- [ ] iTerm2 설치 (권장)
- [ ] Git, tig, Zsh, Tmux, Neovim 설치
- [ ] 유용한 CLI 도구 설치 (bat, lazydocker, glances 등)
- [ ] Oh My Zsh 설치
- [ ] Powerlevel10k 테마 설치
- [ ] Dotfiles 클론 및 install.sh 실행
- [ ] Symlink 생성 확인
- [ ] SSH 키 생성
- [ ] SSH config 설정
- [ ] GitHub에 SSH 키 등록
- [ ] Claude Code 설치 및 로그인
- [ ] Neovim 플러그인 설치

### 선택 단계

- [ ] 추가 Homebrew 패키지 설치
- [ ] LSP 서버 및 포매터 설치
- [ ] Git 계정 설정 확인
- [ ] GitHub SSH 연결 테스트
- [ ] Docker 설치 (lazydocker 사용 시)

---

## 트러블슈팅

### Powerlevel10k 테마가 적용되지 않음

```bash
# .zshrc 확인
grep ZSH_THEME ~/.zshrc

# 다음이 있어야 함:
# ZSH_THEME="powerlevel10k/powerlevel10k"

# 설정 마법사 재실행
p10k configure
```

### Neovim 플러그인 설치 실패

```bash
# Lazy.nvim 재설치
rm -rf ~/.local/share/nvim
nvim

# 또는 수동 설치
:Lazy sync
```

### SSH 연결 실패

```bash
# SSH 에이전트 시작
eval "$(ssh-agent -s)"

# 키 추가
ssh-add ~/.ssh/id_ed25519

# Verbose 모드로 디버그
ssh -vT git@github.com
```

### Claude Code 로그인 실패

```bash
# 기존 credentials 제거
rm ~/.claude/.credentials.json

# 재로그인
claude auth login
```

---

## 참고 자료

- [Homebrew 공식 문서](https://docs.brew.sh/)
- [Oh My Zsh 공식 문서](https://ohmyz.sh/)
- [Powerlevel10k GitHub](https://github.com/romkatv/powerlevel10k)
- [Neovim 공식 문서](https://neovim.io/doc/)
- [lazy.nvim GitHub](https://github.com/folke/lazy.nvim)
- [GitHub SSH 설정 가이드](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)

---

## 다음 단계

설정이 완료되면:

1. **개발 도구 추가 설치**: IDE, Docker, 언어별 런타임 등
2. **Dotfiles 커스터마이징**: 개인 설정 추가 및 backup.sh로 저장
3. **자동화 스크립트 작성**: 반복 작업 자동화
4. **백업 전략 수립**: Time Machine, 클라우드 백업 등

즐거운 코딩 되세요! 🚀

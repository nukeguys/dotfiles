# Claude Code Settings

이 저장소는 Claude Code 프로젝트별 설정을 관리합니다.

## 포함된 설정

### .claude/settings.local.json

프로젝트별 권한 설정 파일입니다. 특정 명령어를 자동으로 승인하도록 설정할 수 있습니다.

```json
{
  "permissions": {
    "allow": ["Bash(git add:*)", "Bash(git commit:*)", "Bash(chmod:*)"]
  }
}
```

## 사용 방법

1. 이 저장소를 프로젝트 루트에 클론하거나 복사
2. `.claude/settings.local.json` 파일을 프로젝트에 맞게 수정
3. Claude Code에서 자동으로 설정 인식

## 주의사항

- `.credentials.json` 파일은 절대 커밋하지 마세요 (OAuth 토큰 포함)
- `settings.local.json`은 프로젝트별로 다를 수 있습니다

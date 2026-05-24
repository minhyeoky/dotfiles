# dotfiles-guard

공개 레포에 **시크릿·개인경로·이메일·위험 파일**이 새어 나가는 것을 막는 **로컬 계층**.
무의존(POSIX awk)으로 동작하며, `gitleaks`가 설치돼 있으면 추가로 사용한다.

이건 defense-in-depth의 한 계층일 뿐이다:

- **GitHub push protection** (서버측, 불가우회, 무료) — provider 시크릿(AWS/GitHub/… 토큰)을 권위적으로 차단. 레포 설정에서 활성화됨.
- **이 로컬 게이트** — 위가 못 잡는 **PII(경로·이메일)·위험 파일명**을 즉시·오프라인에서 차단. 시크릿은 고확신 패턴만 얇게 본다(나머지는 위에 위임).

## 활성화 (머신마다 1회)

git은 보안상 tracked 훅을 자동 실행하지 않는다. clone/pull 후 한 번:

```sh
./.githooks/install.sh        # core.hooksPath=.githooks + 실행권한
```

활성화를 잊으면 zsh가 이 레포에서 **경고**한다(셸 시작/`cd` 시).

## 동작

- **pre-commit** — staged 추가분(내용+파일명) 스캔, 감지 시 커밋 차단
- **pre-push** — remote로 나갈 커밋들 스캔, 감지 시 push 차단 (추가된 줄만 보므로 기존 커밋은 grandfather)

## 감지 대상

- **내용** — private key 블록 · AWS/GitHub/Slack/Google 토큰 · JWT · macOS 홈 절대경로 · 이메일
- **파일명** — `id_rsa`·`id_ed25519`·`*.pem`·`*.key`·`*.p12`·`.env`·`.netrc` 등 (`.env.example`·`*.pub` 예외)

## 오탐 우회

- 내용 오탐이면 그 줄에 `gitguard-ok` 주석.
- 일회성: `git commit --no-verify` / `git push --no-verify`.

## 이력 audit (1회성)

```sh
./.githooks/install.sh audit   # 전체 history에서 이미 커밋된 secret/PII 점검
```

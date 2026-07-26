#!/usr/bin/env bash
# Open an issue / PR / MR of the current repo in the browser, by number.
#
# Usage:
#   open-issue.sh [ref]      ref: 192 (issue) | '#192' (issue) | '!192' (PR/MR)
#   open-issue.sh -n [ref]   print the URL instead of opening it
#   open-issue.sh            no arg -> prompt for ref (this is how the
#                            run-scripts.sh fzf picker invokes it)
#
# ref 문법은 GitLab 표기(#=issue, !=merge request)를 그대로 빌려왔다.
# GitHub은 issue와 PR이 번호 공간을 공유하고 /issues/N 이 PR이면 /pull/N 으로
# 리다이렉트되므로 접두사 없이 번호만 줘도 맞는 곳에 도착한다. GitLab은 issue와
# MR이 번호 공간을 따로 쓰므로 !N 으로 MR을 명시해야 한다.
#
# zsh에서는 '#'(interactive_comments)과 '!'(history expansion) 둘 다 셸이 먼저
# 먹으므로 반드시 따옴표로 감싼다. 접두사 없는 순수 번호만 그냥 써도 된다.
#
# forge 판별은 remote host로 한다: github.com 이면 GitHub, 그 외는 GitLab.
# self-hosted GitLab을 상정한 규칙이라 GitHub Enterprise는 지원하지 않는다.
#
# gh/glab 같은 외부 CLI나 토큰에 의존하지 않는다 — remote URL만으로 웹 URL을
# 조립하므로 사내 GitLab에서도 설정 없이 그대로 동작한다.
set -euo pipefail

DRY=0
if [ "${1:-}" = "-n" ]; then
  DRY=1
  shift
fi

ref="${1:-}"
if [ -z "$ref" ]; then
  read -r -p "issue/MR #: " ref
fi

case "$ref" in
  '!'*) kind="mr"; num="${ref#!}" ;;
  '#'*) kind="issue"; num="${ref#\#}" ;;
  *) kind="issue"; num="$ref" ;;
esac

if ! [[ "$num" =~ ^[0-9]+$ ]]; then
  echo "번호가 아닙니다: '$ref' (예: 192, '#192', '!192')" >&2
  exit 1
fi

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "git 레포가 아닙니다: $PWD" >&2
  exit 1
fi

# origin 우선, 없으면 첫 remote. 둘 다 없으면 조립할 URL이 없다.
remote="origin"
if ! git remote get-url "$remote" >/dev/null 2>&1; then
  remote="$(git remote | head -n 1)"
  if [ -z "$remote" ]; then
    echo "remote가 없어 URL을 만들 수 없습니다." >&2
    exit 1
  fi
fi
url="$(git remote get-url "$remote")"

# --- remote URL -> host + path ------------------------------------------------
# 다루는 형태: git@host:group/repo.git (SCP-like) / ssh://git@host:2222/g/r.git
#              https://host/g/r.git / https://user@host:8443/g/r
scheme=""
case "$url" in
  *://*) scheme="${url%%://*}" ;;
esac

u="${url#*://}"  # scheme 제거 (SCP-like면 그대로)
u="${u#*@}"      # userinfo 제거

if [[ "$u" == *:* ]]; then
  host="${u%%:*}"
  rest="${u#*:}"
  seg="${rest%%/*}"
  if [[ "$rest" == */* && "$seg" =~ ^[0-9]+$ ]]; then
    port="$seg"           # host:port/path
    path="${rest#*/}"
  else
    port=""               # SCP-like host:path
    path="$rest"
  fi
else
  host="${u%%/*}"
  port=""
  path="${u#*/}"
fi

path="${path#/}"
path="${path%/}"
path="${path%.git}"

if [ -z "$host" ] || [ -z "$path" ]; then
  echo "remote URL을 해석하지 못했습니다: $url" >&2
  exit 1
fi

# http(s) remote의 포트는 웹 포트라 살리고, ssh 포트는 웹과 무관하므로 버린다.
web_host="$host"
if [ -n "$port" ] && { [ "$scheme" = "https" ] || [ "$scheme" = "http" ]; }; then
  web_host="${host}:${port}"
fi

if [ "$host" = "github.com" ]; then
  [ "$kind" = "mr" ] && sub="pull" || sub="issues"
else
  [ "$kind" = "mr" ] && sub="-/merge_requests" || sub="-/issues"
fi

target="https://${web_host}/${path}/${sub}/${num}"

if [ "$DRY" = 1 ]; then
  echo "$target"
elif command -v open >/dev/null 2>&1; then
  open "$target"
elif command -v xdg-open >/dev/null 2>&1; then
  xdg-open "$target"
else
  echo "브라우저를 열 수 없어 URL만 출력합니다." >&2
  echo "$target"
fi

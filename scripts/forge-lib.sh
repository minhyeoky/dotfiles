#!/usr/bin/env bash
# Shared remote -> forge (GitHub/GitLab) URL logic. Sourced by open-issue.sh
# and pick-issue.sh; not meant to be run on its own.
#
# forge 판별은 remote host로 한다: github.com 이면 GitHub, 그 외는 GitLab.
# self-hosted GitLab을 상정한 규칙이라 GitHub Enterprise는 지원하지 않는다.
#
# 함수는 sourced 되므로 exit 하지 않고 return 1 + stderr 메시지로 알린다.
#
# forge_load                 현재 레포의 remote에서 FORGE_* 를 채운다
#   FORGE_HOST      remote host (포트 없음)
#   FORGE_WEB_HOST  웹 URL에 쓸 host[:port]
#   FORGE_PATH      group/subgroup/repo
#   FORGE_KIND      github | gitlab
# forge_parse_ref <ref>      FORGE_REF_KIND(issue|mr) / FORGE_REF_NUM 을 채운다
# forge_url <issue|mr> <n>   웹 URL을 stdout에 출력

forge_load() {
  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "git 레포가 아닙니다: $PWD" >&2
    return 1
  fi

  local remote url scheme u host rest seg port path

  # origin 우선, 없으면 첫 remote. 둘 다 없으면 조립할 URL이 없다.
  remote="origin"
  if ! git remote get-url "$remote" >/dev/null 2>&1; then
    remote="$(git remote | head -n 1)"
    if [ -z "$remote" ]; then
      echo "remote가 없어 URL을 만들 수 없습니다." >&2
      return 1
    fi
  fi
  url="$(git remote get-url "$remote")"

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
    return 1
  fi

  FORGE_HOST="$host"
  FORGE_PATH="$path"

  # http(s) remote의 포트는 웹 포트라 살리고, ssh 포트는 웹과 무관하므로 버린다.
  FORGE_WEB_HOST="$host"
  if [ -n "$port" ] && { [ "$scheme" = "https" ] || [ "$scheme" = "http" ]; }; then
    FORGE_WEB_HOST="${host}:${port}"
  fi

  if [ "$host" = "github.com" ]; then
    FORGE_KIND="github"
  else
    FORGE_KIND="gitlab"
  fi
}

# ref 문법은 GitLab 표기(#=issue, !=merge request)를 그대로 빌려왔다.
forge_parse_ref() {
  local ref="$1"
  case "$ref" in
    '!'*) FORGE_REF_KIND="mr"; FORGE_REF_NUM="${ref#!}" ;;
    '#'*) FORGE_REF_KIND="issue"; FORGE_REF_NUM="${ref#\#}" ;;
    *) FORGE_REF_KIND="issue"; FORGE_REF_NUM="$ref" ;;
  esac
  if ! [[ "$FORGE_REF_NUM" =~ ^[0-9]+$ ]]; then
    echo "번호가 아닙니다: '$ref' (예: 192, '#192', '!192')" >&2
    return 1
  fi
}

forge_url() {
  local kind="$1" num="$2" sub
  if [ "$FORGE_KIND" = "github" ]; then
    if [ "$kind" = "mr" ]; then sub="pull"; else sub="issues"; fi
  else
    if [ "$kind" = "mr" ]; then sub="-/merge_requests"; else sub="-/issues"; fi
  fi
  printf 'https://%s/%s/%s/%s\n' "$FORGE_WEB_HOST" "$FORGE_PATH" "$sub" "$num"
}

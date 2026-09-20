#!/usr/bin/env python3
"""에이전트 함대 상태를 4개 소스로 조인해 트리아지 표를 뽑는다. 읽기 전용."""

import glob
import json
import os
import subprocess
import sys
from datetime import datetime, timezone

TAIL_BYTES = 256 * 1024  # 트랜스크립트 1.5MB까지 자라므로 꼬리만 읽는다
PROJECTS = os.path.expanduser("~/.claude/projects")


def run(cmd, timeout=60):
    try:
        p = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
        return p.stdout if p.returncode == 0 else ""
    except (subprocess.TimeoutExpired, FileNotFoundError):
        return ""


def roster():
    out = run(["claude", "agents", "--json", "--all"], timeout=90)
    if not out.strip():
        sys.exit("claude agents --json 실패 — claude가 PATH에 있는지 확인")
    return json.loads(out)


def proc_command(pid):
    out = run(["ps", "-p", str(pid), "-o", "command="])
    return out.strip()


def tail_entries(path):
    """파일 꼬리에서 파싱 가능한 JSON 라인만 회수."""
    size = os.path.getsize(path)
    with open(path, "rb") as f:
        if size > TAIL_BYTES:
            f.seek(size - TAIL_BYTES)
            f.readline()  # 잘린 첫 줄 버림
        raw = f.read().decode("utf-8", errors="replace")
    entries = []
    for line in raw.splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            entries.append(json.loads(line))
        except json.JSONDecodeError:
            continue
    return entries


def transcript_facts(session_id):
    """(마지막 활동 UTC, 멈춘 이유, 라인수, 바이트) — 없으면 None."""
    hits = glob.glob(os.path.join(PROJECTS, "*", f"{session_id}.jsonl"))
    if not hits:
        return None
    path = hits[0]
    size = os.path.getsize(path)
    entries = tail_entries(path)

    last_ts = None
    for e in reversed(entries):
        if e.get("timestamp"):
            last_ts = e["timestamp"]
            break

    # 꼬리 쪽 API 에러가 곧 멈춘 이유다 (429 spend limit 등)
    reason = None
    for e in reversed(entries):
        if e.get("isApiErrorMessage") or e.get("error"):
            status = e.get("apiErrorStatus") or ""
            kind = e.get("error") or "api_error"
            text = ""
            msg = e.get("message") or {}
            content = msg.get("content")
            if isinstance(content, list):
                for c in content:
                    if isinstance(c, dict) and c.get("type") == "text":
                        text = c.get("text", "")[:120]
                        break
            reason = f"{kind} {status} {text}".strip()
            break

    return {"path": path, "size": size, "last": last_ts, "reason": reason}


def age_days(iso):
    if not iso:
        return None
    try:
        t = datetime.fromisoformat(iso.replace("Z", "+00:00"))
    except ValueError:
        return None
    return (datetime.now(timezone.utc) - t).total_seconds() / 86400


def git_state(cwd):
    if not os.path.isdir(cwd):
        return "cwd 없음"
    branch = run(["git", "-C", cwd, "rev-parse", "--abbrev-ref", "HEAD"]).strip()
    if not branch:
        return "git 아님"
    dirty = run(["git", "-C", cwd, "status", "--porcelain"]).strip()
    n = len(dirty.splitlines()) if dirty else 0
    return f"{branch} ({n} dirty)" if n else f"{branch} (clean)"


def classify(s, cmd, tf):
    """유령 / 사망 / 정체 / 대기 / 진행 / 완료."""
    if "bg-spare" in cmd:
        return "유령", "데몬 예비 슬롯 — 실제 작업 아님"
    if not cmd:
        return "유령", "프로세스 없음 (죽은 pid)"
    if tf and tf["reason"]:
        return "사망", tf["reason"]
    days = age_days(tf["last"]) if tf else None
    if s.get("state") == "done":
        return "완료", "결과 방치 — 리뷰/커밋 필요할 수 있음"
    if s.get("status") == "busy":
        return "진행", "손대지 말 것"
    if days is not None and days >= 3:
        return "정체", f"{days:.0f}일간 활동 없음"
    if s.get("state") == "blocked":
        return "대기", "입력 대기 가능성 — attach해 확인"
    return "유휴", ""


def main():
    sessions = roster()
    rows = []
    cwds = {}

    for s in sessions:
        pid = s.get("pid")
        sid = s.get("sessionId", "")
        cmd = proc_command(pid) if pid else ""
        tf = transcript_facts(sid) if sid else None
        bucket, note = classify(s, cmd, tf)
        days = age_days(tf["last"]) if tf else None
        cwd = s.get("cwd", "")
        if bucket not in ("유령",) and cwd:
            cwds.setdefault(cwd, None)
        rows.append(
            {
                "bucket": bucket,
                "note": note,
                "name": (s.get("name") or "")[:44],
                "kind": s.get("kind", ""),
                "cwd": cwd,
                "repo": os.path.basename(cwd),
                "sid": sid,
                "pid": pid,
                "last": tf["last"] if tf else None,
                "days": days,
                "lines_bytes": tf["size"] if tf else 0,
            }
        )

    for cwd in cwds:
        cwds[cwd] = git_state(cwd)

    order = ["사망", "정체", "대기", "완료", "진행", "유휴", "유령"]
    rows.sort(key=lambda r: (order.index(r["bucket"]), -(r["days"] or 0)))

    print(f"# 함대 트리아지 — 세션 {len(rows)}개\n")
    print(f"{'분류':<5} {'미활동':>7}  {'종류':<12} {'repo':<24} 이름 / 사유")
    print("-" * 100)
    for r in rows:
        d = f"{r['days']:.0f}d" if r["days"] is not None else "-"
        print(f"{r['bucket']:<5} {d:>7}  {r['kind']:<12} {r['repo'][:24]:<24} {r['name']}")
        if r["note"]:
            print(f"{'':<5} {'':>7}  └─ {r['note']}")

    print("\n# 세션이 물고 있는 워킹트리")
    for cwd, state in sorted(cwds.items()):
        print(f"  {os.path.basename(cwd):<24} {state}")

    print("\n# attach용 세션 ID")
    for r in rows:
        if r["bucket"] in ("사망", "정체", "대기", "완료") and r["sid"]:
            print(f"  {r['sid'][:8]}  {r['bucket']}  {r['name']}")


if __name__ == "__main__":
    main()

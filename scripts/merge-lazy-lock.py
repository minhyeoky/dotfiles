#!/usr/bin/env python3
"""git merge driver for lazy-lock.json: merges per plugin instead of per line.

Plugin lines sit next to each other, so a textual 3-way merge conflicts whenever two
sides bump neighbours. Here each key is merged on its own; a key changed on both sides
keeps the current side (%A: HEAD on `git stash pop`, the checked-out branch on `git merge`)
and the dropped value is listed on stderr. `:Lazy restore` then installs what the lock says.

usage (git config): driver = python3 scripts/merge-lazy-lock.py %O %A %B
"""
import json
import sys


def load(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def main():
    base_path, cur_path, other_path = sys.argv[1:4]
    base, cur, other = load(base_path), load(cur_path), load(other_path)
    out = {}
    for key in sorted(set(base) | set(cur) | set(other)):
        b, c, o = base.get(key), cur.get(key), other.get(key)
        if c == b:
            v = o  # only the other side changed (or removed) it
        elif o == b or o == c:
            v = c  # only the current side changed it, or both agree
        else:
            v = c  # changed differently on both sides: keep the current side
            sys.stderr.write("merge-lazy-lock: %s kept %s, dropped %s\n" % (key, c, o))
        if v is not None:
            out[key] = v
    # lazy.nvim's own layout: one plugin per line, sorted keys
    def obj(v):
        return "{ " + ", ".join("%s: %s" % (json.dumps(a), json.dumps(b)) for a, b in v.items()) + " }"
    lines = ["  %s: %s" % (json.dumps(k), obj(v)) for k, v in out.items()]
    with open(cur_path, "w", encoding="utf-8") as f:
        f.write("{\n" + ",\n".join(lines) + "\n}\n")


main()

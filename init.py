#!/usr/bin/env python3
import json
import os

BASE_DIR = os.path.abspath(os.path.dirname(__file__))

with open(os.path.join(BASE_DIR, "meta.json"), mode='r') as f:
    meta = json.load(f)

def replace_env(s: str):
    if s.startswith("$"):
        var = os.environ.get(s[1:])
        assert var is not None
        return var
    
    return s

for idx, m in enumerate(meta):
    src_path = os.path.join(BASE_DIR, *[replace_env(p) for p in m["src"]["path"]])
    dest_path = os.path.join(*[replace_env(p) for p in m["dst"]["path"]])
    
    os.system(f"ln -f -s -v {src_path} {dest_path}")

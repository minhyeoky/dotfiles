#!/usr/bin/env python3
"""
TODO: Logging
"""
import argparse
import contextlib
import logging
import os
import time

_HOME = os.environ["HOME"]
_ALACRITTY_FILE = f"{_HOME}/.config/alacritty/alacritty.yml"
_ALACRITTY_LOCK = f"{_HOME}/.alacritty_lock"
_OPACITY_STEP = 0.1


def main(increase: bool):

    with open(_ALACRITTY_FILE, mode="r") as f:
        new_lines = []
        window_section = False
        for line in f.readlines():
            new_lines.append(line)
            if "window:" in line:
                window_section = True
                continue

            if not window_section:
                continue

            if "opacity:" not in line:
                continue

            opacity = float(line.split(":")[1].strip())

            if increase:
                new_opacity = min(opacity + _OPACITY_STEP, 1.0)
            else:
                new_opacity = max(opacity - _OPACITY_STEP, 0.0)

            new_lines[-1] = "  opacity: " + str(new_opacity) + "\n"
            window_section = False

    with open(_ALACRITTY_FILE, mode="w") as f:
        f.writelines(new_lines)


@contextlib.contextmanager
def _alacritty_lock():
    r = 0
    pid = os.getpid()
    while True:
        if not os.path.exists(_ALACRITTY_LOCK):
            with open(_ALACRITTY_LOCK, mode="w") as f:
                f.write(str(pid))

        with open(_ALACRITTY_LOCK, mode="r") as f:
            d = f.readline()
            if int(d.strip()) == pid:
                break
        r += 1

        if r > 3:
            raise Exception("Can not acquire Alacritty lock.")

        time.sleep(0.1)
    try:
        yield
    finally:
        os.remove(_ALACRITTY_LOCK)


if __name__ == "__main__":
    argparser = argparse.ArgumentParser()
    argparser.add_argument("--inc", default="y", choices=["y", "n"])
    args = argparser.parse_args()
    try:
        with _alacritty_lock():
            main(True if args.inc == "y" else False)
    except Exception as e:
        logging.warning("Unknown Exception!", exc_info=True)

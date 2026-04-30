#!/usr/bin/env python3
import subprocess
import time
import os

PAUSE_FLAG = os.path.expanduser("~/.clipboard-cleaner.pause")

def get_clipboard():
    try:
        return subprocess.run(["pbpaste"], capture_output=True, text=True).stdout
    except Exception:
        return ""

def set_clipboard(text):
    subprocess.run(["pbcopy"], input=text, text=True)

def clean(text):
    lines = text.split("\n")
    lines = [line.rstrip() for line in lines]
    return "\n".join(lines)

def main():
    last = get_clipboard()
    while True:
        time.sleep(0.4)
        if os.path.exists(PAUSE_FLAG):
            last = get_clipboard()
            continue
        current = get_clipboard()
        if current != last:
            cleaned = clean(current)
            if cleaned != current:
                set_clipboard(cleaned)
                last = cleaned
            else:
                last = current

if __name__ == "__main__":
    main()
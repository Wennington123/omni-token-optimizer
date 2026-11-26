#!/usr/bin/env python3
"""
Local hook (zero LLM tokens) - Observation Trimmer
Intercepts and compresses tool outputs (terminal, logs, CSV, JSON) before they
reach the model API, applying the CoACT and TRC principles.
"""

import sys

MAX_LINES = 40
MAX_CHARS = 1500

def trim_observation(text: str) -> str:
    if not text or len(text) <= MAX_CHARS:
        return text

    lines = text.splitlines()
    if len(lines) <= MAX_LINES:
        return text

    head = lines[:15]
    tail = lines[-15:]

    error_lines = [l for l in lines[15:-15] if any(kw in l.lower() for kw in ['error', 'exception', 'failed', 'fatal', 'traceback'])]

    trimmed_count = len(lines) - 30 - len(error_lines)

    result = []
    result.extend(head)
    if error_lines:
        result.append(f"\n[... {len(error_lines)} ERROR LINES DETECTED IN THE MIDDLE ...]")
        result.extend(error_lines[:10])
    result.append(f"\n[... OBSERVATION TRIMMED BY HOOK: {trimmed_count} lines / {len(text)} chars removed ...]\n")
    result.extend(tail)

    return "\n".join(result)

if __name__ == '__main__':
    raw_input = sys.stdin.read()
    sys.stdout.write(trim_observation(raw_input))

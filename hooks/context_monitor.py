#!/usr/bin/env python3
"""
Local hook (zero LLM tokens) - Context Monitor
Estimates the session history size from the JSONL transcript and, above the
limit, injects a warning that triggers Sub-Skill 04 (state-compactor).

Command Code protocol: JSON payload on stdin, JSON response on stdout.
Silent (exit 0, empty stdout) when below the limit.
"""

import json
import os
import sys

TOKEN_THRESHOLD = int(os.environ.get("OMNI_TOKEN_THRESHOLD", "8000"))


def estimate_tokens(text: str) -> int:
    return len(text) // 4


def main():
    try:
        payload = json.load(sys.stdin)
    except Exception:
        payload = {}

    transcript_path = payload.get("transcript_path", "")
    content = ""
    if transcript_path and os.path.isfile(transcript_path):
        try:
            with open(transcript_path, "r", encoding="utf-8", errors="ignore") as f:
                content = f.read()
        except OSError:
            content = ""

    tokens = estimate_tokens(content)
    if tokens <= TOKEN_THRESHOLD:
        return

    print(json.dumps({
        "suppressOutput": True,
        "systemMessage": f"[omni-token-optimizer] Estimated history of ~{tokens} tokens (limit: {TOKEN_THRESHOLD}).",
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "additionalContext": (
                f"[TOKEN_WARNING] Session history estimated at ~{tokens} tokens (limit: {TOKEN_THRESHOLD}). "
                "RECOMMENDED ACTION: summarize the state in a <HISTORY_SUMMARY> block "
                "(REASONING, VARS, TODO, COMPLETED, GUARDRAILS) — subskills/04-state-compactor.md — "
                "and replace older tool results with [output cleared] placeholders."
            ),
        },
    }, ensure_ascii=False))


if __name__ == "__main__":
    sys.exit(main())

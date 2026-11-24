#!/usr/bin/env python3
"""
Hook Local (Zero Tokens LLM) - Context Monitor
Estima o tamanho do histórico da sessão a partir do transcript JSONL e,
acima do limite, injeta um aviso para acionar a Sub-Skill 04 (state-compactor).

Protocolo Command Code: payload JSON no stdin, resposta JSON no stdout.
Silencioso (exit 0, stdout vazio) quando abaixo do limite.
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
        "systemMessage": f"[omni-token-optimizer] Histórico estimado em ~{tokens} tokens (limite: {TOKEN_THRESHOLD}).",
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "additionalContext": (
                f"[TOKEN_WARNING] Histórico da sessão estimado em ~{tokens} tokens (limite: {TOKEN_THRESHOLD}). "
                "AÇÃO RECOMENDADA: resuma o estado na estrutura <HISTORY_SUMMARY> "
                "(REASONING, VARS, TODO, COMPLETED, GUARDRAILS) — subskills/04-state-compactor.md — "
                "e substitua resultados antigos de ferramentas por placeholders [output cleared]."
            ),
        },
    }, ensure_ascii=False))


if __name__ == "__main__":
    sys.exit(main())

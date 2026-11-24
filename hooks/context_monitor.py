#!/usr/bin/env python3
"""
Hook Local (Zero Tokens LLM) - Context Monitor
Calcula uma estimativa da contagem de tokens do histórico acumulativo
e emite um alerta de gatilho para acionar a Sub-Skill 04 (state-compactor).
"""

import sys

TOKEN_THRESHOLD = 8000

def estimate_tokens(text: str) -> int:
    return len(text) // 4

def main():
    if len(sys.argv) > 1:
        with open(sys.argv[1], 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
    else:
        content = sys.stdin.read()

    tokens = estimate_tokens(content)
    
    if tokens > TOKEN_THRESHOLD:
        print(f"[TOKEN_WARNING] Histórico atual estimado em ~{tokens} tokens (Limite: {TOKEN_THRESHOLD}).")
        print("[TOKEN_WARNING] AÇÃO RECOMENDADA: Invoque a compaginação de estado <HISTORY_SUMMARY> (subskills/04-state-compactor.md).")
    else:
        print(f"[TOKEN_OK] Histórico atual em ~{tokens} tokens.")

if __name__ == '__main__':
    main()

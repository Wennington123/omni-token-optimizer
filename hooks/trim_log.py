#!/usr/bin/env python3
"""Hook de 0-token: corta observação (log/output) antes de entrar no contexto.

Uso:
    python3 trim_log.py < arquivo.log                    # modo padrão (erro + cauda)
    python3 trim_log.py --grep 'pattern' [-C 3] < f.log  # só linhas que casam + contexto
    python3 trim_log.py --tail 50 < f.log                # últimas N linhas
    cmd 2>&1 | python3 trim_log.py                       # pipeline direto

Saída: observação cortada para colar no contexto, com marcador de truncamento.
Corta em script, nunca em LLM: determinístico, reversível, 0 token.
"""
import argparse
import re
import sys

ERROR_PAT = re.compile(
    r"error|fail|panic|fatal|exception|traceback|assert|exit code|denied|refused",
    re.IGNORECASE,
)


def dedupe(lines):
    seen = {}
    for ln in lines:
        seen[ln] = seen.get(ln, 0) + 1
    return [f"{ln}  (x{n})" if n > 1 else ln for ln, n in seen.items()]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--grep", help="regex de whitelist; só linhas que casam")
    ap.add_argument("-C", type=int, default=3, help="linhas de contexto no --grep")
    ap.add_argument("--tail", type=int, help="últimas N linhas")
    ap.add_argument("--head", type=int, help="primeiras N linhas")
    ap.add_argument("--max", type=int, default=120, help="teto de linhas na saída")
    args = ap.parse_args()

    lines = sys.stdin.read().splitlines()
    total = len(lines)

    if args.grep:
        rx = re.compile(args.grep)
        keep = set()
        for i, ln in enumerate(lines):
            if rx.search(ln):
                for j in range(max(0, i - args.C), min(total, i + args.C + 1)):
                    keep.add(j)
        lines = [lines[i] for i in sorted(keep)]
    elif args.tail is not None:
        lines = lines[-args.tail:]
    elif args.head is not None:
        lines = lines[: args.head]
    else:
        hits = [i for i, ln in enumerate(lines) if ERROR_PAT.search(ln)]
        if hits:
            keep = set()
            for i in hits:
                for j in range(max(0, i - 2), min(total, i + 3)):
                    keep.add(j)
            lines = [lines[i] for i in sorted(keep)]
        else:
            lines = lines[-args.max:]

    lines = dedupe(lines)
    if len(lines) > args.max:
        dropped = len(lines) - args.max
        lines = lines[: args.max // 2] + [f"[... {dropped} linhas cortadas; use offset ...]"] + lines[-args.max // 2 :]

    print(f"# observação: {total} linhas -> {len(lines)}")
    print("\n".join(lines))


if __name__ == "__main__":
    main()

#!/usr/bin/env bash
# omni-token-optimizer — instalador de uma linha
#
#   curl -fsSL https://raw.githubusercontent.com/Wennington123/omni-token-optimizer/main/install.sh | bash
#
# Opções:
#   --dir DIR     raiz de skills do agente (padrão: auto-detecta)
#   --uninstall   remove a skill instalada
#   -h, --help    mostra esta ajuda
#
# Auto-detecção da raiz de skills: ~/.commandcode/skills, ~/.claude/skills,
# ~/.config/opencode/skills; se nenhuma existir, usa ~/.claude/skills.
set -euo pipefail

REPO_URL="https://github.com/Wennington123/omni-token-optimizer"
SKILL_NAME="omni-token-optimizer"
HOOK_FILES="observation_trimmer.py context_monitor.py"
TARGET_DIR=""
UNINSTALL=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dir) TARGET_DIR="$2"; shift 2 ;;
    --uninstall) UNINSTALL=1; shift ;;
    -h|--help) grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "omni-token-optimizer: argumento desconhecido: $1" >&2; exit 1 ;;
  esac
done

detect_skills_root() {
  local d
  for d in "$HOME/.commandcode/skills" "$HOME/.claude/skills" "$HOME/.config/opencode/skills"; do
    [[ -d "$d" ]] && { echo "$d"; return; }
  done
  echo "$HOME/.claude/skills"
}

SKILLS_ROOT="${TARGET_DIR:-$(detect_skills_root)}"
SKILL_DIR="$SKILLS_ROOT/$SKILL_NAME"
CC_HOOKS="$HOME/.commandcode/hooks"

if [[ "$UNINSTALL" -eq 1 ]]; then
  rm -rf "$SKILL_DIR"
  if [[ -d "$CC_HOOKS" ]]; then
    for f in $HOOK_FILES; do rm -f "$CC_HOOKS/$f"; done
  fi
  echo "Removido: $SKILL_DIR (e hooks de $CC_HOOKS, se havia)"
  exit 0
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "==> Baixando $REPO_URL"
if command -v git >/dev/null 2>&1 && git clone --quiet --depth 1 "$REPO_URL.git" "$TMP/repo" 2>/dev/null; then
  :
else
  curl -fsSL "$REPO_URL/archive/refs/heads/main.tar.gz" | tar -xz -C "$TMP"
  mv "$TMP/$SKILL_NAME-main" "$TMP/repo"
fi

[[ -f "$TMP/repo/SKILL.md" ]] || { echo "erro: SKILL.md não encontrado no download" >&2; exit 1; }

echo "==> Instalando em $SKILL_DIR"
mkdir -p "$SKILL_DIR"
cp "$TMP/repo/SKILL.md" "$TMP/repo/AGENTS.md" "$SKILL_DIR/"
cp -r "$TMP/repo/subskills" "$TMP/repo/hooks" "$SKILL_DIR/"
chmod +x "$SKILL_DIR/hooks/"*.py

if [[ -d "$CC_HOOKS" ]]; then
  cp -f "$SKILL_DIR/hooks/"*.py "$CC_HOOKS/"
  chmod +x "$CC_HOOKS/"*.py
  echo "==> Hooks copiados para $CC_HOOKS"
fi

echo "==> Arquivos instalados:"
find "$SKILL_DIR" -type f | sed "s|^$SKILL_DIR/|    |"

cat <<'WIRE'

==> Para ativar o context monitor no Command Code / Claude Code, adicione ao
    settings.json (config testada; ajuste o limiar via OMNI_TOKEN_THRESHOLD):

  "hooks": {
    "PreToolUse": [{
      "matcher": "shell",
      "hooks": [{
        "type": "command",
        "command": "OMNI_TOKEN_THRESHOLD=200000 python3 $HOME/.commandcode/hooks/context_monitor.py",
        "timeout": 5
      }]
    }]
  }

    O monitor lê o transcript da sessão (protocolo JSON de hooks) e injeta o
    aviso de compactação da subskill 04 quando o histórico passa do limite.
    observation_trimmer.py fica para agentes Python customizados — hooks de
    Command Code não substituem o output que o modelo vê (só injetam contexto).
    A skill em si é auto-descoberta pelo agente na próxima sessão.
WIRE
echo "==> Pronto. Reinicie a sessão do agente para carregar a skill."

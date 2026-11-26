#!/usr/bin/env bash
# omni-token-optimizer — one-line installer
#
#   curl -fsSL https://raw.githubusercontent.com/Wennington123/omni-token-optimizer/main/install.sh | bash
#
# Options:
#   --dir DIR     agent skills root (default: auto-detect)
#   --uninstall   remove the installed skill
#   -h, --help    show this help
#
# Skills root auto-detection: ~/.commandcode/skills, ~/.claude/skills,
# ~/.config/opencode/skills; if none exists, falls back to ~/.claude/skills.
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
    -h|--help) grep '^#' "$0" | grep -v '^#!' | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "omni-token-optimizer: unknown argument: $1" >&2; exit 1 ;;
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
OPENCODE_DIR="$HOME/.config/opencode"

if [[ "$UNINSTALL" -eq 1 ]]; then
  rm -rf "$SKILL_DIR"
  if [[ -d "$CC_HOOKS" ]]; then
    for f in $HOOK_FILES; do rm -f "$CC_HOOKS/$f"; done
  fi
  if [[ -d "$OPENCODE_DIR/plugins/$SKILL_NAME" ]]; then
    rm -rf "$OPENCODE_DIR/plugins/$SKILL_NAME"
    echo "Removed: $OPENCODE_DIR/plugins/$SKILL_NAME"
  fi
  if [[ -d "$OPENCODE_DIR/skills/$SKILL_NAME" ]]; then
    rm -rf "$OPENCODE_DIR/skills/$SKILL_NAME"
    echo "Removed: $OPENCODE_DIR/skills/$SKILL_NAME"
  fi
  echo "Removed: $SKILL_DIR (and hooks from $CC_HOOKS, if present)"
  exit 0
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "==> Downloading $REPO_URL"
if command -v git >/dev/null 2>&1 && git clone --quiet --depth 1 "$REPO_URL.git" "$TMP/repo" 2>/dev/null; then
  :
else
  curl -fsSL "$REPO_URL/archive/refs/heads/main.tar.gz" | tar -xz -C "$TMP"
  mv "$TMP/$SKILL_NAME-main" "$TMP/repo"
fi

[[ -f "$TMP/repo/SKILL.md" ]] || { echo "error: SKILL.md not found in the download" >&2; exit 1; }

echo "==> Installing into $SKILL_DIR"
mkdir -p "$SKILL_DIR"
cp "$TMP/repo/SKILL.md" "$TMP/repo/AGENTS.md" "$SKILL_DIR/"
cp -r "$TMP/repo/subskills" "$TMP/repo/hooks" "$SKILL_DIR/"
chmod +x "$SKILL_DIR/hooks/"*.py

if [[ -d "$CC_HOOKS" ]]; then
  cp -f "$SKILL_DIR/hooks/"*.py "$CC_HOOKS/"
  chmod +x "$CC_HOOKS/"*.py
  echo "==> Hooks copied to $CC_HOOKS"
fi

if [[ -d "$OPENCODE_DIR" ]]; then
  mkdir -p "$OPENCODE_DIR/plugins"
  rm -rf "$OPENCODE_DIR/plugins/$SKILL_NAME"
  cp -r "$TMP/repo/plugins/opencode" "$OPENCODE_DIR/plugins/$SKILL_NAME"
  echo "==> OpenCode plugin installed at $OPENCODE_DIR/plugins/$SKILL_NAME"

    # On machines with more than one agent, the skill may have landed in another
  # root (e.g. ~/.commandcode/skills); OpenCode only sees ~/.config/opencode/skills.
  OPENCODE_SKILL_DIR="$OPENCODE_DIR/skills/$SKILL_NAME"
  if [[ "$SKILL_DIR" != "$OPENCODE_SKILL_DIR" ]]; then
    mkdir -p "$OPENCODE_SKILL_DIR"
    cp -r "$SKILL_DIR/." "$OPENCODE_SKILL_DIR/"
    echo "==> OpenCode skill installed at $OPENCODE_SKILL_DIR"
  fi
fi

echo "==> Installed files:"
find "$SKILL_DIR" -type f | sed "s|^$SKILL_DIR/|    |"

cat <<'WIRE'

==> To enable the context monitor in Command Code / Claude Code, add this to
    settings.json (tested config; tune the threshold via OMNI_TOKEN_THRESHOLD):

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

    The monitor reads the session transcript (hooks JSON protocol) and injects
    the subskill 04 compaction warning once the history crosses the limit.
    observation_trimmer.py is meant for custom Python agents — Command Code
    hooks cannot replace the output the model sees (they only inject context).
    The skill itself is auto-discovered by the agent on the next session.
WIRE

if [[ -d "$OPENCODE_DIR" ]]; then
  cat <<WIRE2

==> OpenCode (v2): add this to $OPENCODE_DIR/opencode.json —

  {
    "\$schema": "https://opencode.ai/config.json",
    "instructions": ["$OPENCODE_DIR/skills/$SKILL_NAME/SKILL.md"],
    "plugins": ["$OPENCODE_DIR/plugins/$SKILL_NAME"]
  }

  Skill and plugin reload on save (no restart). Threshold and trim options:
  see the "OpenCode Integration" section in the README.
WIRE2
fi
echo "==> Done. Restart the agent session to load the skill."

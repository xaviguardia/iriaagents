#!/usr/bin/env bash
# =============================================================================
# Lanzar agente Claude Code para {{TITULO}}
#
# Uso:
#   ./tasks/{{NOMBRE}}/run-claude.sh              # No-interactivo (print mode)
#   ./tasks/{{NOMBRE}}/run-claude.sh --interactive # Conversación interactiva
#   ./tasks/{{NOMBRE}}/run-claude.sh --dry-run     # Solo mostrar prompt
# =============================================================================

set -euo pipefail
{{CD_TOPLEVEL}}

TASK_DIR="tasks/{{NOMBRE}}"
DRY_RUN=false
INTERACTIVE=false

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --interactive) INTERACTIVE=true ;;
  esac
done

PROMPT=$(cat "$TASK_DIR/PROMPT.md")

if $DRY_RUN; then
  echo "=== PROMPT ($(echo "$PROMPT" | wc -w) words) ==="
  echo "$PROMPT"
  exit 0
fi

if $INTERACTIVE; then
  echo "Lanzando Claude Code interactivo..."
  claude "$PROMPT"
else
  echo "Lanzando Claude Code no-interactivo..."
  claude --dangerously-skip-permissions -p "$PROMPT"
fi

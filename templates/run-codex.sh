#!/usr/bin/env bash
# =============================================================================
# Lanzar agente Codex para {{TITULO}}
#
# Uso:
#   ./tasks/{{NOMBRE}}/run-codex.sh              # No-interactivo
#   ./tasks/{{NOMBRE}}/run-codex.sh --interactive # Interactivo
#   ./tasks/{{NOMBRE}}/run-codex.sh --dry-run     # Solo mostrar prompt
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
  echo "Lanzando Codex interactivo..."
  codex \
    -C "$(pwd)" \
    -s workspace-write \
    "$PROMPT"
else
  echo "Lanzando Codex no-interactivo..."
  codex exec \
    -C "$(pwd)" \
    -s workspace-write \
    "$PROMPT"
fi

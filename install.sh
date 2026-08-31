#!/usr/bin/env bash
# =============================================================================
# install.sh — Instala los commands de iriaagents en ~/.claude/commands/
#
# Uso:
#   ./install.sh             # Instala todos los commands (symlinks)
#   ./install.sh --copy      # Instala copiando en vez de symlinkear
#   ./install.sh --force     # Sobreescribe si ya existen
#   ./install.sh --list      # Lista los commands disponibles
#   ./install.sh --uninstall # Elimina los symlinks instalados
# =============================================================================

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMANDS_SRC="$REPO_DIR/commands"
COMMANDS_DST="$HOME/.claude/commands"
COPY_MODE=false
FORCE=false
LIST=false
UNINSTALL=false

for arg in "$@"; do
  case "$arg" in
    --copy)      COPY_MODE=true ;;
    --force)     FORCE=true ;;
    --list)      LIST=true ;;
    --uninstall) UNINSTALL=true ;;
  esac
done

# --- list ---
if $LIST; then
  echo "Commands disponibles en iriaagents:"
  for f in "$COMMANDS_SRC"/*.md; do
    [ -e "$f" ] || continue
    name=$(basename "$f" .md)
    if [ -L "$COMMANDS_DST/$name.md" ]; then
      status="instalado (symlink)"
    elif [ -f "$COMMANDS_DST/$name.md" ]; then
      status="instalado (copia)"
    else
      status="no instalado"
    fi
    echo "  /$name — $status"
  done
  exit 0
fi

# --- uninstall ---
if $UNINSTALL; then
  echo "Desinstalando commands de iriaagents..."
  for f in "$COMMANDS_SRC"/*.md; do
    [ -e "$f" ] || continue
    name=$(basename "$f" .md)
    target="$COMMANDS_DST/$name.md"
    if [ -L "$target" ]; then
      rm "$target"
      echo "  eliminado symlink: $target"
    elif [ -f "$target" ]; then
      if $FORCE; then
        rm "$target"
        echo "  eliminado (--force): $target"
      else
        echo "  AVISO: $target existe pero no es symlink — usa --force para eliminar"
      fi
    fi
  done
  [ -f "$HOME/.claude/iriaagents_path" ] && rm "$HOME/.claude/iriaagents_path" && echo "  eliminado: ~/.claude/iriaagents_path"
  echo "Listo."
  exit 0
fi

# --- install ---
mkdir -p "$COMMANDS_DST"

# Escribe la ruta del repo para que los skills puedan encontrar los templates
# sin paths hardcodeados — cualquier usuario en cualquier máquina.
echo "$REPO_DIR" > "$HOME/.claude/iriaagents_path"
echo "Ruta del repo guardada en ~/.claude/iriaagents_path"

echo "Instalando commands en $COMMANDS_DST..."

for f in "$COMMANDS_SRC"/*.md; do
  [ -e "$f" ] || continue
  name=$(basename "$f" .md)
  target="$COMMANDS_DST/$name.md"

  if [ -e "$target" ] && ! $FORCE; then
    echo "  OMITIDO (ya existe): /$name  →  usa --force para sobreescribir"
    continue
  fi

  if [ -e "$target" ] || [ -L "$target" ]; then
    rm "$target"
  fi

  if $COPY_MODE; then
    cp "$f" "$target"
    echo "  copiado:   /$name"
  else
    ln -s "$f" "$target"
    echo "  symlink:   /$name  →  $f"
  fi
done

echo ""
echo "Commands instalados. Disponibles en Claude Code, Grok y quien cargue ~/.claude/commands:"
for f in "$COMMANDS_SRC"/*.md; do
  [ -e "$f" ] || continue
  name=$(basename "$f" .md)
  echo "  /$name"
done

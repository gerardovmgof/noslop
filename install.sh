#!/usr/bin/env bash
# Instala /noslop y las skills de la guía "Stop AI Slop" en ~/.claude.
# Idempotente: se puede correr en cada arranque de sesión.
#   ./install.sh           instala o actualiza
#   ./install.sh --quiet   sin salida salvo errores
set -uo pipefail

QUIET=0; [[ "${1:-}" == "--quiet" ]] && QUIET=1
log() { [[ $QUIET -eq 1 ]] || echo "noslop: $*"; }

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
SKILLS="$CLAUDE_DIR/skills"
SRC="${NOSLOP_CACHE:-$HOME/.cache/noslop/src}"
REFS="$CLAUDE_DIR/noslop"
mkdir -p "$SKILLS" "$CLAUDE_DIR/commands" "$SRC" "$REFS"

# repo | ruta de la skill dentro del repo ("-" = no es skill, solo referencia/CLI)
REPOS=(
  "pbakaus/impeccable|.claude/skills/impeccable"
  "nextlevelbuilder/ui-ux-pro-max-skill|.claude/skills/ui-ux-pro-max"
  "Leonxlnx/taste-skill|skills/taste-skill skills/redesign-skill"
  "hardikpandya/stop-slop|."
  "blader/humanizer|."
  "zarazhangrui/frontend-slides|."
  "cathrynlavery/diagram-design|skills/diagram-design"
  "VoltAgent/awesome-design-md|-"
  "google-labs-code/design.md|-"
)

fetch() {  # clona o actualiza (shallow); no falla si no hay red y ya existe copia
  local repo="$1" dir="$SRC/${1#*/}"
  if [[ -d "$dir/.git" ]]; then
    git -C "$dir" pull -q --depth 1 --ff-only 2>/dev/null || log "sin actualizar $repo (uso copia local)"
  else
    git clone -q --depth 1 "https://github.com/$repo" "$dir" 2>/dev/null || { echo "noslop: no pude clonar $repo" >&2; return 1; }
  fi
}

copy_skill() {  # copia una carpeta de skill a ~/.claude/skills/<name>, sin .git
  local from="$1" name
  name="$(sed -n 's/^name:[[:space:]]*//p' "$from/SKILL.md" | head -1 | tr -d '"'"'"'')"
  [[ -n "$name" ]] || name="$(basename "$from")"
  rm -rf "${SKILLS:?}/$name"
  mkdir -p "$SKILLS/$name"
  tar -C "$from" --exclude=.git --exclude=.github -cf - . | tar -C "$SKILLS/$name" -xf -
  log "skill $name"
}

for entry in "${REPOS[@]}"; do
  repo="${entry%%|*}"; paths="${entry#*|}"
  fetch "$repo" || continue
  [[ "$paths" == "-" ]] && continue
  for p in $paths; do
    [[ -f "$SRC/${repo#*/}/$p/SKILL.md" ]] && copy_skill "$SRC/${repo#*/}/$p" \
      || echo "noslop: falta SKILL.md en $repo/$p" >&2
  done
done

# Biblioteca de DESIGN.md de marcas reales (para --ref)
if [[ -d "$SRC/awesome-design-md/design-md" ]]; then
  rm -rf "$REFS/design-md"
  cp -r "$SRC/awesome-design-md/design-md" "$REFS/design-md"
  log "referencias: $(ls "$REFS/design-md" | wc -l) marcas en $REFS/design-md"
fi

# Copia reutilizable del instalador en ~/.claude/noslop (salvo si ya corre desde ahí)
if [[ "$HERE" != "$REFS" ]]; then
  cp "$HERE/install.sh" "$REFS/install.sh"
  mkdir -p "$REFS/commands" && cp "$HERE/commands/noslop.md" "$REFS/commands/"
fi
cp "$HERE/commands/noslop.md" "$CLAUDE_DIR/commands/noslop.md"
log "comando /noslop instalado en $CLAUDE_DIR/commands/noslop.md"

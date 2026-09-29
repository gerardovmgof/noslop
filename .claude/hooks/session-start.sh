#!/usr/bin/env bash
# SessionStart: reinstala /noslop y sus skills en cada sesión.
# Necesario en Claude Code en la web, donde el contenedor es efímero.
set -uo pipefail
bash "$CLAUDE_PROJECT_DIR/install.sh" --quiet || true

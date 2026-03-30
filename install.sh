#!/usr/bin/env bash
# install.sh — Installs Praxis Core skills into a target project
# Usage: ./install.sh /path/to/your/project
#
# What it does:
#   1. Copies skills/ into <project>/.claude/skills/
#   2. Does NOT touch CLAUDE.md or any project files — run /setup or /init after install

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

TARGET="$1"

if [ -z "$TARGET" ]; then
  echo "Usage: ./install.sh /path/to/your/project"
  exit 1
fi

if [ ! -d "$TARGET" ]; then
  echo "Error: target directory does not exist: $TARGET"
  exit 1
fi

DEST="$TARGET/.claude/skills"
mkdir -p "$DEST"

echo "Installing Praxis Core into $DEST ..."
cp -r "$SCRIPT_DIR/skills/"* "$DEST/"
echo "Done."
echo ""
echo "Next steps:"
echo "  cd $TARGET"
echo "  Open Claude Code and run:"
echo "    /init    — if this is a new project with no code yet"
echo "    /setup   — if this project already has code (auto-detects your stack)"

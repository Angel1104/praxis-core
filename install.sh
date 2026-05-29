#!/usr/bin/env bash
# install.sh — Installs SDM skills into a target project (legacy path)
# For plugin-based install, use: /plugin marketplace add <path> && /plugin install sdm@comocom
#
# Usage: ./install.sh /path/to/your/project
# What it does: copies skills/ into <project>/.claude/skills/

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

echo "Installing SDM skills into $DEST ..."
cp -r "$SCRIPT_DIR/skills/"* "$DEST/"
echo "Done."
echo ""
echo "Next steps:"
echo "  cd $TARGET"
echo "  Open Claude Code and run:"
echo "    /intake  describe your change or incident"

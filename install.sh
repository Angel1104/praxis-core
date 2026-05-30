#!/usr/bin/env bash
# install.sh — Installs Praxis skills into a target project
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

echo "Installing Praxis skills into $DEST ..."
cp -r "$SCRIPT_DIR/skills/"* "$DEST/"
echo "Done."
echo ""
echo "Next steps:"
echo "  cd $TARGET"
echo "  Open Claude Code and run:"
echo "    /plan  describe what you want to build"

#!/usr/bin/env bash
# install.sh — Installs Praxis skills into a target project
#
# Usage: ./install.sh /path/to/your/project
# Supports: Claude Code, OpenCode, Antigravity

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

install_to() {
  local dest="$TARGET/$1"
  mkdir -p "$dest"
  cp -r "$SCRIPT_DIR/skills/"* "$dest/"
  echo "  ✓ $1"
}

echo "Installing Praxis skills..."
install_to ".claude/skills"
install_to ".opencode/skills"
install_to ".agent/skills"

echo ""
echo "Done. Open your AI agent and run:"
echo "  /plan  describe what you want to build"

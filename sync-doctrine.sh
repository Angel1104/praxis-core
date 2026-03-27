#!/usr/bin/env bash
# sync-doctrine.sh — Syncs doctrine/ source files to all bundled skill references/
# Run this after editing any file in doctrine/ to keep all skills in sync.
# Usage: ./sync-doctrine.sh

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCTRINE="$SCRIPT_DIR/doctrine"
SKILLS="$SCRIPT_DIR/skills"

sync_file() {
  local src="$1"
  local filename="$(basename "$src")"
  local count=0
  for dest in "$SKILLS"/*/references/"$filename"; do
    if [ -f "$dest" ]; then
      cp "$src" "$dest"
      count=$((count + 1))
    fi
  done
  if [ "$count" -gt 0 ]; then
    echo "  synced $filename → $count skill(s)"
  fi
}

echo "Syncing doctrine → skills/*/references/ ..."

sync_file "$DOCTRINE/directive-execution-principle.md"
sync_file "$DOCTRINE/lifecycle-stage-rules.md"
sync_file "$DOCTRINE/artifact-contracts.md"
sync_file "$DOCTRINE/architecture-principles.md"
sync_file "$DOCTRINE/boundary-rules.md"
sync_file "$DOCTRINE/port-adapter-rules.md"
sync_file "$DOCTRINE/orchestration-vs-domain.md"
sync_file "$DOCTRINE/review-severity-model.md"
sync_file "$DOCTRINE/finding-classification-rules.md"
sync_file "$DOCTRINE/evidence-and-citation-rules.md"
sync_file "$DOCTRINE/implementation-planning-rules.md"
sync_file "$DOCTRINE/spec-quality-rules.md"
sync_file "$DOCTRINE/testing-quality-rules.md"
sync_file "$DOCTRINE/backlog-persistence-rules.md"
sync_file "$DOCTRINE/contract-impact-rules.md"
sync_file "$DOCTRINE/lessons-learned-rules.md"

echo "Done."

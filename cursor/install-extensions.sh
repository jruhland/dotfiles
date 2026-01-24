#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXTENSIONS_FILE="$SCRIPT_DIR/extensions.txt"

if [ ! -f "$EXTENSIONS_FILE" ]; then
  echo "Error: extensions.txt not found"
  exit 1
fi

if ! command -v cursor &> /dev/null; then
  echo "Cursor not found, skipping extension installation"
  exit 0
fi

echo "Installing Cursor extensions..."
while IFS= read -r ext; do
  [ -z "$ext" ] && continue
  echo "  Installing $ext"
  cursor --install-extension "$ext" --force
done < "$EXTENSIONS_FILE"

echo "All extensions installed"
